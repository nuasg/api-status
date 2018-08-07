class RunTestsJob < ApplicationJob
  queue_as :default

  @responses = Hash.new
  @requests = Hash.new
  @ids = Hash.new

  def perform(*args)
    # Setup hash
    results = Hash.new

    # Run each test and save the resultset in the results Hash under the test path
    Tests::TESTS.each do |path, test_spec|
      results[path] = test(path, test_spec)
    end

    # Connect to the Redis server
    redis = Redis.new

    # Save info to Redis
    save_to_redis results, redis
    test_data_age redis

    # Start with empty set of failures
    failures = []

    # Save the "worst" failure so that we can decide whether or not to set an alert, and if so, how severe
    worst = nil

    # Iterate over all results
    results.each do |path, result|
      # Check each test for this path

      result.each do |test_name, test_result|
        # If the test passed, we don't care.
        next if test_result[:type] == "pass"

        # If worst is still nil, it's this result (warn or fail) by default
        worst ||= test_result[:type]

        # Only allow the result to get worse (warn->fail, not fail->warn)
        worst = test_result[:type] if worst == "warn"
        worst = test_result[:type] if test_result[:type] == "fail"

        # Setup a Hash for this failure
        add = Hash.new
        add["name"] = test_name
        add["result"] = test_result[:type]
        add["message"] = test_result[:message]
        add["path"] = path

        # Add it to the failures
        failures << add
      end
    end

    # Save the time that all this happened
    tests_run = DateTime.now

    # Permanently save the results of what happened so they can be accessed at /results/:id
    save_to_models results, tests_run, redis

    # Update the last run time in Redis
    redis.set "last-run", tests_run

    # If we had failures and there weren't already known failures, send an email and set a notification.
    unless failures.empty? || !Notice.find_by(active: true, auto: true).nil?
      # Find all administrators of this system
      users = User.where(admin: true)

      emails = []

      # Add each user's email to a list
      users.each do |user|
        emails << user.email
      end

      # Always send an email at least to asg-technology
      emails << "asg-technology@u.northwestern.edu"

      # Mail each email using the alert_mailer view, passing failures and IDs in
      emails.each do |email|
        AlertMailer.with(to: email, failures: failures, timestamp: tests_run.strftime("%Y-%m-%d %H:%M:%S"), ids: @ids)
            .alert_email.deliver_now
      end

      # Create a new notice
      notice = Notice.new

      # Set the notice content and save it
      notice.title    = "API #{worst == "warn" ? "Warnings" : "Errors"} [Auto-Generated]"
      notice.content  = "Automated API tests have revealed potential issues with the API. Our developers have been notified and will be looking into the issue shortly."
      notice.active   = true
      notice.auto     = true
      notice.severity = worst == "warn" ? "warning" : "danger"

      notice.save
    end

    # Set this to run again in 5 minutes unless it was triggered by an end user
    RunTestsJob.set(wait: 5.minutes).perform_later(false) unless args[0]
  end

  def test(path, test_spec)
    # Allow relative paths in tests
    base_url = "https://api.asg.northwestern.edu"

    # Create a new hash for the results of tests for this path
    results = Hash.new

    # Make hashes if not set already
    @requests ||= Hash.new
    @responses ||= Hash.new

    @requests[path] ||= Hash.new
    @responses[path] ||= Hash.new

    # Run each test
    test_spec.each do |test|
      name    = test[:name]
      params  = test[:params]
      count   = test[:count]
      expect  = test[:expect]

      # Create full URI and add API Key
      url = URI.parse(base_url)
      url.path = path
      url.query = URI.encode_www_form(params + [["key", Northwestern::API_KEY]])

      # Save full path (including domain and protocol) for access and use later
      @requests[path][name] = url.to_s

      # This might cause an error
      begin
        raw = Net::HTTP.get url

        # Save full response data for access and use later
        @responses[path][name] = raw

        res = JSON.parse raw

        # The root of the response should be an Array unless something went wrong (arity mismatch, possibly)
        unless res.is_a? Array
          results[name] = {
              :type => "fail",
              :message => "Wrong type of JSON response received. Expected array at root."
          }

          # Result saved, stop processing
          next
        end

        # None of the provided tests should return an empty array
        if res.length == 0
          results[name] = {
              :type => "fail",
              :message => "Result set was empty"
          }

          # Result saved, stop processing
          next
        end

        # Pick a result at random; we can't test each element in the response set (each course, each term, ...)
        random = rand 0...res.length
        tst = res[random]

        # Warn if there are more fields per response element than expected
        if tst.length > expect.length
          results[name] = {
              :type => "warn",
              :message => "Expected #{expect.length} field(s), got #{tst.length}"
          }

          # Result saved, stop processing
          next
        # Fail if there are less fields per response element than expected
        elsif tst.length < expect.length
          results[name] = {
              :type => "fail",
              :message => "Expected #{expect.length} field(s), got #{tst.length}"
          }

          # Result saved, stop processing
          next
        end

        # Assume it didn't fail (entering a nested loop)
        fail = false

        # Try each expected key->value pair and make sure it lines up
        expect.each do |key, value|
          # If we can't find an expected key, fail
          unless tst.key?(key.to_s)
            results[name] = {
                :type => "fail",
                :message => "Response missing expected field #{key}"
            }

            # Result saved, stop processing
            fail = true
            break
          end

          # If multiple types were specified, test against each one
          if value.is_a? Array
            truth_table = value.map do |x|
              # Test nil if that's the type, otherwise check the type itself
              x.nil? ? tst[key.to_s].nil? : tst[key.to_s].is_a?(x)
            end

            # If any of them are true, the result matched one of the types. Otherwise, fail.
            unless truth_table.include? true
              results[name] = {
                  :type => "fail",
                  :message => "Response key \"#{key}\" not of any type #{value} (is a #{tst[key.to_s].class})"
              }

              # Result saved, stop processing
              fail = true
              break
            end
          # We don't care what it is if the expected value was "nil"
          elsif value.nil?
          # There was only one type specified and it wasn't nil, so test it
          else
            # If the result was of the right type, continue. Otherwise, fail.
            unless tst[key.to_s].is_a?(value)
              results[name] = {
                  :type => "fail",
                  :message => "Response key \"#{key}\" not of type #{value} (is a #{tst[key.to_s].class})"
              }

              # Result saved, stop processing
              fail = true
              break
            end
          end
        end

        # Check inner loop value and fail if it failed.
        next if fail

        # Test the number of results
        case count
        when "many"
          # Warn for one results when "many" specified
          if res.length == 1
            results[name] = {
                :type => "warn",
                :message => "Expected many result(s), got 1"
            }

            # Result saved, stop processing
            next
          end
        else
          # Warn for different amount than specified (not "many")
          if res.length != count
            results[name] = {
                :type => "warn",
                :message => "Expected #{count} result(s), got #{res.length}"
            }

            # Result saved, stop processing
            next
          end
        end
      rescue JSON::JSONError => e
        # If the result was not parseable, save as a failed result
        results[name] = {
            :type => "fail",
            :message => "Bad JSON: " + e.message
        }

        # Stop testing this
        next
      end

      # If we got this far, there was no error.
      results[name] = {
          :type => "pass",
          :message => "Nothing to report."
      }
    end

    # Return the resultset
    results
  end

  def save_to_models(results, timestamp, redis)
    # Iterate through each test path
    results.each do |path, tests|

      # Iterate through each test for the given test path
      tests.each do |name, resultset|
        res = TestResult.new

        # Set appropriate information
        res.time_run = timestamp
        res.name = name
        res.result = resultset[:type]
        res.message = resultset[:message]
        res.response = @responses[path][name]
        res.path = path
        res.request = @requests[path][name]

        res.save

        # Save to Redis
        redis.hset path, "test-#{name}-id", res.id

        # Conditionally set IDs for later access
        @ids ||= Hash.new
        @ids[path] ||= Hash.new
        @ids[path][name] = res.id
      end
    end

    # Remove old results to prevent DB bloat
    TestResult.all.order(time_run: :desc).offset(10000).each &:destroy
  end

  def save_to_redis(results, redis)
    # Iterate through each path
    results.each do |path, outerresultsset|

      # Iterate through each test for this path
      outerresultsset.each do |name, resultset|

        # Save results
        redis.hset path, "test-#{name}-result", resultset[:type]
        redis.hset path, "test-#{name}-message", resultset[:message]
      end
    end
  end

  def test_data_age(redis)
    # Get terms to compare against
    terms = Northwestern.terms

    # Get latest term
    latest = terms[0]

    # Split into season and year
    split = latest["name"].split ' '
    data_year = split[0].to_i
    data_quarter_string = split[1]

    quarter_map = {
        :winter => 1,
        :spring => 2,
        :summer => 3,
        :fall => 4
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

    @data = Hash.new

    if data_year > current_year
      # We're good
      @data["status"] = "success"
    elsif data_year == current_year
      # Compare quarters
      diff = data_quarter - current_quarter

      if diff >= 2
        # We're good
        @data["status"] = "success"
      elsif diff >= 0
        # Warning
        @data["status"] = "warning"
      else
        # Danger
        @data["status"] = "danger"
      end
    elsif data_year < current_year
      # Danger
      @data["status"] = "danger"
    end

    @data["current"] = latest["name"]

    # Save results to Redis
    redis.hset "/data/age", "string", @data["current"]
    redis.hset "/data/age", "result", @data["status"]
  end
end
