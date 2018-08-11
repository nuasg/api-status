class RunTestsJob < ApplicationJob
  queue_as :default

  def perform(enqueue_next = true, redis = Redis.new, tests = Tests::TESTS)
    # Setup hash
    results = []

    # Store the large category info
    categories = Hash.new

    # Setup all test information
    tests.each do |path, test_info|
      # Map the category path to a name
      categories[path] = test_info[:category_name]

      test_index = 0
      # Setup each test result with the test_spec specified
      test_info[:tests].each do |test|
        tr = TestResult.new

        tr.path = path
        tr.test_spec = test
        tr.name = test[:name]
        tr.test_index = test_index

        test_index += 1

        results << tr
      end
    end

    # Start with empty set of failures
    failures = []

    # Save the "worst" failure so that we can decide whether or not to set an alert, and if so, how severe
    worst = 0

    timestamp = nil

    redis.pipelined do
      # Query the API and test the responses
      results.each &:query
      results.each &:test

      categories.each do |path, name|
        redis.set path, name
      end

      redis.sadd 'categories', categories.keys

      # Save info to Redis (also saves to database)
      results.each do |result|
        result.save_to_redis redis
      end

      # Check to see how old our data is
      test_data_age redis

      # Iterate through all results; find the failures
      results.each do |result|
        result_type = result.result

        if TestResult.results[result_type] > worst
          worst = TestResult.results[result_type]
        end

        if TestResult.results[result_type] > 0
          failures << result
        end
      end

      timestamp = DateTime.now

      # Update the last run time in Redis
      redis.set "last-run", timestamp
    end

    # If we had failures and there weren't already known failures, send an email and set a notification.
    unless failures.empty? || Notice.has_active_auto_notice?
      # Mail each email using the alert_mailer view, passing failures and IDs in
      AlertMailer.with(failures: failures, timestamp: timestamp.strftime("%Y-%m-%d %H:%M:%S"))
          .alert_email.deliver_now

      # Create a new notice
      notice = Notice.new

      # Set the notice content and save it
      notice.title = "API #{worst == 1 ? "Warnings" : "Errors"} [Auto-Generated]"
      notice.content  = "Automated API tests have revealed potential issues with the API. Our developers have been notified and will be looking into the issue shortly."
      notice.active   = true
      notice.auto     = true
      notice.severity = worst == 1 ? "warning" : "danger"

      notice.save
    end

    # Set this to run again in 5 minutes unless it was triggered by an end user
    RunTestsJob.set(wait: 5.minutes).perform_later if enqueue_next
  end

  def test_data_age(redis)
    # Get terms to compare against
    terms = Northwestern.terms

    # Get latest term
    latest = terms[0]

    # Split into season and year
    split = latest['name'].split ' '
    data_year = split[0].to_i
    data_quarter_string = split[1]

    quarter_map = {
        winter: 1,
        spring: 2,
        summer: 3,
        fall: 4
    }

    # Convert quarter to a number
    data_quarter = quarter_map[data_quarter_string.downcase.to_sym]

    # Get the current month and convert it (roughly) to a quarter
    current_month = DateTime.now.strftime("%-m").to_i
    current_quarter = nil

    if current_month <= 3
      current_quarter = 1
    elsif current_month <= 6
      current_quarter = 2
    elsif current_month <= 8
      current_quarter = 3
    elsif current_month <= 12
      current_quarter = 4
    end

    # Get the current year
    current_year = DateTime.now.strftime("%Y").to_i

    data = Hash.new

    if data_year > current_year
      # We're good
      data['status'] = 'pass'
    elsif data_year == current_year
      # Compare quarters
      diff = data_quarter - current_quarter

      if diff >= 2
        # We're good
        data['status'] = 'pass'
      elsif diff >= 0
        # Warning
        data['status'] = 'warn'
      else
        # Danger
        data['status'] = 'fail'
      end
    elsif data_year < current_year
      # Danger
      data['status'] = 'fail'
    end

    data['current'] = latest['name']

    # Save results to Redis
    redis.hset '/data/age', 'string', data['current']
    redis.hset '/data/age', 'result', data['status']
  end
end
