class TestResult < ApplicationRecord
  validates :name, :time_run, :result, :response, :path, :request, :message, presence: true
  attr_accessor :test_spec, :test_index, :result_code


  enum result: [:pass, :warn, :fail]

  def query
    # Allow relative paths in tests
    base_url = "https://api.asg.northwestern.edu"

    # Create full URI and add API Key
    url = URI.parse base_url
    url.path = path
    url.query = URI.encode_www_form(self.test_spec[:params] + [["key", Northwestern::API_KEY]])

    # Save full path (including domain and protocol) for access and use later
    self.request = url.to_s

    # Perform the API request
    response = Net::HTTP.get url

    # Save the raw response for further parsing
    self.response = response
    self.time_run = DateTime.now
  end

  def test
    test = self.test_spec

    count = test[:count]
    expect = test[:expect]

    # This might cause an error (parsing JSON)
    begin
      raw = self.response

      res = JSON.parse raw

      # The root of the response should be an Array unless something went wrong (arity mismatch, possibly)
      unless res.is_a? Array
        self.result = :fail
        self.message = 'Wrong type of JSON response received. Expected array at root.'
        self.result_code = 0x41

        return
      end

      # None of the provided tests should return an empty array
      if res.length == 0
        self.result = :fail
        self.message = 'Result set was empty.'
        self.result_code = 0x42

        return
      end

      # Pick a result at random; we can't test each element in the response set (each course, each term, ...)
      random = rand 0...res.length
      result_element = res[random]

      # Warn if there are more fields per response element than expected
      if result_element.length > expect.length
        self.result = :warn
        self.message = "Expected #{expect.length} field(s), got #{result_element.length}"
        self.result_code = 0x43

        return
        # Fail if there are less fields per response element than expected
      elsif result_element.length < expect.length
        self.result = :fail
        self.message = "Expected #{expect.length} field(s), got #{result_element.length}"
        self.result_code = 0x44

        return
      end

      # Try each expected key->value pair and make sure it lines up
      expect.each do |key, value|
        # If we can't find an expected key, fail
        unless result_element.key?(key.to_s)
          self.result = :fail
          self.message = "Response missing expected field #{key}"
          self.result_code = 0x45

          return
        end

        # If multiple types were specified, test against each one
        if value.is_a? Array
          truth_table = value.map do |x|
            # Test nil if that's the type, otherwise check the type itself
            x.nil? ? result_element[key.to_s].nil? : result_element[key.to_s].is_a?(x)
          end

          # If any of them are true, the result matched one of the types. Otherwise, fail.
          unless truth_table.include? true
            self.result = :fail
            self.message = "Response key \"#{key}\" not of any type #{value} (is a #{result_element[key.to_s].class})"
            self.result_code = 0x46

            return
          end

          # We don't care what it is if the expected value was "nil"
        elsif value.nil?
          # There was only one type specified and it wasn't nil, so test it
        else
          # If the result was of the right type, continue. Otherwise, fail.
          unless result_element[key.to_s].is_a?(value)
            self.result = :fail
            self.message = "Response key \"#{key}\" not of type #{value} (is a #{result_element[key.to_s].class})"
            self.result_code = 0x46

            return
          end
        end
      end

      # Test the number of results
      case count
      when "many"
        # Warn for one results when "many" specified
        if res.length == 1
          self.result = :warn
          self.message = 'Expected many results, got 1'
          self.result_code = 0x47

          return
        end
      else
        # Warn for different amount than specified (not "many")
        if res.length != count
          self.result = :warn
          self.message = "Expected #{count} result(s), got #{res.length}"
          self.result_code = 0x47

          return
        end
      end
    rescue JSON::JSONError => e
      # If the result was not parseable, save as a failed result
      self.result = :fail
      self.message = "Bad JSON: #{e.message}"
      self.result_code = 0x40

      return
    end

    # If we got this far, there was no error.
    self.result = :pass
    self.result_code = 0x00
    self.message = 'Nothing to report.'
  end

  # @param [Redis] redis
  def save_to_redis(redis)
    # Check that this model has an ID; make one if not
    if self.new_record?
      self.save!
    end

    prefix = "#{self.path}-#{self.test_index}"

    # Set redis hash values
    redis.hset prefix, 'id', self.id
    redis.hset prefix, 'name', self.name
    redis.hset prefix, 'result', self.result.to_s
    redis.hset prefix, 'message', self.message
    redis.hset prefix, 'index', self.test_index
  end

  # @param [Redis] redis
  def self.redis_get(redis, path)
    search = "#{path}-*"

    cursor = 0

    test_names = []

    loop do
      result = redis.scan cursor, match: search

      cursor = result[0].to_i
      test_names += result[1]

      test_names.uniq!

      break if cursor == 0
    end

    tests = test_names.map do |i|
      redis.hgetall i
    end

    worst = 0
    tests.each do |test|
      worst = TestResult.results[test[:result.to_s]] if (TestResult.results[test[:result.to_s]] > worst)

      test.deep_symbolize_keys!
    end

    return {
        worst: TestResult.results.key(worst),
        tests: tests.sort_by! do |test|
          test[:index].to_i
        end
    }
  end

  # @param [Redis] redis
  def self.redis_get_all(redis)
    categories = redis.smembers 'categories'

    results = Hash.new

    categories.each do |category|
      results[category] = {
          category_name: redis.get(category),
          results: self.redis_get(redis, category)
      }
    end

    return results
  end
end

class ErrorCode
  SUCCESS = 0x00
  INVALID_JSON = 0x40
  INCORRECT_JSON = 0x41
  EMPTY_RESULTSET = 0x42
  TOO_MANY_FIELDS = 0x43
  TOO_FEW_FIELDS = 0x44
  MISSING_FIELD = 0x45
  FIELD_TYPE_MISMATCH = 0x46
  ELEMENT_COUNT_MISMATCH = 0x47
end
