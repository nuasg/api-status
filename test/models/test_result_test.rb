require 'test_helper'

class TestResultTest < ActiveSupport::TestCase
  TEST_SPEC = {
      :name => 'Test',
      :params => [
          %w(test test)
      ],
      :count => 'many',
      :expect => {
          :id => Integer,
          :title => String,
          :room => [String, nil]
      }
  }

  TEST_SPEC_TWO = {
      :name => 'Test',
      :params => [
          %w(test test)
      ],
      :count => 2,
      :expect => {
          :id => Integer,
          :title => String,
          :room => [String, nil]
      }
  }

  TEST_SPEC_ONE = {
      :name => 'Test',
      :params => [
          %w(test test)
      ],
      :count => 1,
      :expect => {
          :id => Integer,
          :title => String,
          :room => [String, nil]
      }
  }

  test "saving" do
    tr = TestResult.new
    assert_not tr.save, "Test Result Validation Failed"
    tr.time_run = DateTime.now
    assert_not tr.save, "Test Result Validation Failed"
    tr.name = "Test"
    assert_not tr.save, "Test Result Validation Failed"
    tr.result = :pass
    assert_not tr.save, "Test Result Validation Failed"
    tr.response = '{}'
    assert_not tr.save, "Test Result Validation Failed"
    tr.path = "/test"
    assert_not tr.save, "Test Result Validation Failed"
    tr.request = 'https://asdf/'
    assert_not tr.save, "Test Result Validation Failed"
    tr.message = "nulle part"

    assert tr.valid?
    assert tr.save
  end

  test "good_response" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '[{"id": 3, "title": "test", "room": null},{"id": 3, "title": "test", "room": null},{"id": 3, "title": "test", "room": null}]'

    tr.test

    assert tr.result == 'pass'
    assert tr.result_code == ErrorCode::SUCCESS
  end

  test "invalid_json" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '["id": 150763, "title": "Finite Mathematics", "term": "2017 Winter", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "202-0", "section": "81", "room": "Lunt Hall 104", "meeting_days": "MoWeFr", "start_time": "14:00", "end_time": "14:50", "seats": 30, "topic": null, "component": "LEC", "class_num": 20647, "course_id": 2446}, {"id": 175280, "title": "Single Variable Calculus I", "term": "2018 Winter", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "212-0", "section": "71", "room": "Kresge Centennial Hall 2-435", "meeting_days": "MoWeFr", "start_time": "13:00", "end_time": "13:50", "seats": 22, "topic": null, "component": "LEC", "class_num": 20402, "course_id": 17787}, {"id": 170769, "title": "Single Variable Calculus II", "term": "2018 Spring", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "213-0", "section": "73", "room": "Fisk Hall 114", "meeting_days": "MoWeFr", "start_time": "13:00", "end_time": "13:50", "seats": 20, "topic": null, "component": "LEC", "class_num": 37564, "course_id": 17823}, {"id": 170768, "title": "Single Variable Calculus II", "term": "2018 Spring", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "213-0", "section": "71", "room": "Fisk Hall 114", "meeting_days": "MoWeFr", "start_time": "13:00", "end_time": "13:50", "seats": 30, "topic": null, "component": "LEC", "class_num": 34803, "course_id": 17823}, {"id": 165753, "title": "Single Variable Calculus III", "term": "2018 Fall", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "214-0", "section": "81", "room": "Technological Institute M128", "meeting_days": "MoWeFr", "start_time": "14:00", "end_time": "14:50", "seats": 25, "topic": null, "component": "LEC", "class_num": 17530, "course_id": 17824}, {"id": 150767, "title": "Differential Calculus of One-Variable Functions", "term": "2017 Winter", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "220-0", "section": "51", "room": "Technological Institute LG66", "meeting_days": "MoWeFr", "start_time": "11:00", "end_time": "11:50", "seats": 25, "topic": null, "component": "LEC", "class_num": 20650, "course_id": 2449}, {"id": 150766, "title": "Differential Calculus of One-Variable Functions", "term": "2017 Winter", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "220-0", "section": "41", "room": "Technological Institute LG66", "meeting_days": "MoWeFr", "start_time": "10:00", "end_time": "10:50", "seats": 25, "topic": null, "component": "LEC", "class_num": 20649, "course_id": 2449}, {"id": 132376, "title": "Differential Calculus of One-Variable Functions", "term": "2015 Fall", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "220-0", "section": "63", "room": "Technological Institute LG66", "meeting_days": "MoWeFr", "start_time": "12:00", "end_time": "12:50", "seats": 30, "topic": null, "component": "LEC", "class_num": 10902, "course_id": 2449}, {"id": 137402, "title": "Integral Calculus of One Variable Functions", "term": "2016 Winter", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "224-0", "section": "71", "room": "Lunt Hall 107", "meeting_days": "MoWeFr", "start_time": "13:00", "end_time": "13:50", "seats": 34, "topic": null, "component": "LEC", "class_num": 22403, "course_id": 2450}, {"id": 141609, "title": "Integral Calculus of One Variable Functions", "term": "2016 Spring", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "224-0", "section": "51", "room": "Technological Institute M177", "meeting_days": "MoWeFr", "start_time": "11:00", "end_time": "11:50", "seats": 31, "topic": null, "component": "LEC", "class_num": 37761, "course_id": 2450}, {"id": 155985, "title": "Integral Calculus of One-Variable Functions", "term": "2017 Spring", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "224-0", "section": "61", "room": "Lunt Hall 103", "meeting_days": "MoWeFr", "start_time": "12:00", "end_time": "12:50", "seats": 22, "topic": null, "component": "LEC", "class_num": 34085, "course_id": 2450}, {"id": 175294, "title": "Integral Calculus of One-Variable Functions", "term": "2018 Winter", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "224-0", "section": "53", "room": "Lunt Hall 104", "meeting_days": "MoWeFr", "start_time": "11:00", "end_time": "11:50", "seats": 32, "topic": null, "component": "LEC", "class_num": 20286, "course_id": 2450}, {"id": 155984, "title": "Integral Calculus of One-Variable Functions", "term": "2017 Spring", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "224-0", "section": "51", "room": "Lunt Hall 107", "meeting_days": "MoWeFr", "start_time": "11:00", "end_time": "11:50", "seats": 22, "topic": null, "component": "LEC", "class_num": 34084, "course_id": 2450}, {"id": 133964, "title": "Differential Calculus of Multivariable Functions", "term": "2015 Fall", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "230-0", "section": "71", "room": "Technological Institute M345", "meeting_days": "MoWeFr", "start_time": "13:00", "end_time": "13:50", "seats": 34, "topic": null, "component": "LEC", "class_num": 18423, "course_id": 2451}, {"id": 160946, "title": "Differential Calculus of Multivariable Functions", "term": "2017 Fall", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "230-0", "section": "43", "room": "Technological Institute A110", "meeting_days": "MoWeFr", "start_time": "10:00", "end_time": "10:50", "seats": 26, "topic": null, "component": "LEC", "class_num": 11130, "course_id": 2451}, {"id": 141637, "title": "Elementary Differential Equations", "term": "2016 Spring", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "250-0", "section": "31", "room": "Technological Institute L160", "meeting_days": "MoWeFr", "start_time": "09:00", "end_time": "09:50", "seats": 30, "topic": null, "component": "LEC", "class_num": 30726, "course_id": 2458}, {"id": 165801, "title": "Foundations of Higher Mathematics", "term": "2018 Fall", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "300-0", "section": "71", "room": "Technological Institute LG62", "meeting_days": "MoTuWeFr", "start_time": "13:00", "end_time": "13:50", "seats": 20, "topic": null, "component": "LEC", "class_num": 10934, "course_id": 2472}, {"id": 170811, "title": "Complex Analysis", "term": "2018 Spring", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "325-0", "section": "51", "room": "Technological Institute M166", "meeting_days": "MoTuWeFr", "start_time": "11:00", "end_time": "11:50", "seats": 21, "topic": null, "component": "LEC", "class_num": 34742, "course_id": 2471}, {"id": 146645, "title": "Chaotic Dynamical Systems", "term": "2016 Fall", "instructor": "Daniel Cuzzocreo", "subject": "MATH", "catalog_num": "354-1", "section": "31", "room": "Lunt Hall 103", "meeting_days": "MoWeThFr", "start_time": "09:00", "end_time": "09:50", "seats": 23, "topic": null, "component": "LEC", "class_num": 13473, "course_id": 2479}]'

    tr.test

    assert tr.result == 'fail'
    assert tr.result_code == ErrorCode::INVALID_JSON
  end

  test "incorrect_json" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '{"test": "fail"}'

    tr.test

    assert tr.result == 'fail'
    assert tr.result_code == ErrorCode::INCORRECT_JSON
  end

  test "empty_resultset" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '[]'

    tr.test

    assert tr.result == 'fail'
    assert tr.result_code == ErrorCode::EMPTY_RESULTSET
  end

  test "too_many_fields" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '[{"id": 1, "title": "xd", "room": null, "extra": "extra"}]'

    tr.test

    assert tr.result == 'warn'
    assert tr.result_code == ErrorCode::TOO_MANY_FIELDS
  end

  test "too_few_fields" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '[{"id": 1, "title": "xd"}]'

    tr.test

    assert tr.result == 'fail'
    assert tr.result_code == ErrorCode::TOO_FEW_FIELDS
  end

  test "missing_field" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '[{"id": 1, "title": "xd", "building": "test"}]'

    tr.test

    assert tr.result == 'fail'
    assert tr.result_code == ErrorCode::MISSING_FIELD
  end

  test "incorrect_field_type" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '[{"id": 1, "title": 3, "room": "test"}]'

    tr.test

    assert tr.result == 'fail'
    assert tr.result_code == ErrorCode::FIELD_TYPE_MISMATCH

    tr.response = '[{"id": 1, "title": "test", "room": 4}]'

    tr.test

    assert tr.result == 'fail'
    assert tr.result_code == ErrorCode::FIELD_TYPE_MISMATCH
  end

  test "element_count_mismatch" do
    tr = TestResult.new
    tr.test_spec = TEST_SPEC
    tr.response = '[{"id": 1, "title": "test", "room": "test"}]'

    tr.test

    assert tr.result == 'warn'
    assert tr.result_code == ErrorCode::ELEMENT_COUNT_MISMATCH

    tr.test_spec = TEST_SPEC_TWO
    tr.response = '[{"id": 1, "title": "test", "room": "test"}]'

    tr.test

    assert tr.result == 'warn'
    assert tr.result_code == ErrorCode::ELEMENT_COUNT_MISMATCH

    tr.test_spec = TEST_SPEC_ONE
    tr.response = '[{"id": 1, "title": "test", "room": "test"},{"id": 1, "title": "test", "room": "test"}]'

    tr.test

    assert tr.result == 'warn'
    assert tr.result_code == ErrorCode::ELEMENT_COUNT_MISMATCH
  end

  test 'save_to_redis' do
    tr = TestResult.new

    tr.path = '/test'
    tr.time_run = DateTime.now
    tr.name = 'Test'
    tr.result = 'pass'
    tr.response = '[]'
    tr.request = 'http://api/'
    tr.message = 'Message'
    tr.test_index = 3

    redis = MockRedis.new

    tr.save_to_redis redis

    assert_not tr.id.nil?

    assert_equal tr.id.to_s, redis.hget('/test-3', 'id')
    assert_equal tr.name, redis.hget('/test-3', 'name')
    assert_equal tr.result, redis.hget('/test-3', 'result')
    assert_equal tr.message, redis.hget('/test-3', 'message')
    assert_equal tr.test_index.to_s, redis.hget('/test-3', 'index')

    assert_equal 5, redis.hgetall('/test-3').length

    redis.flushall
  end

  test 'query' do
    tr = TestResult.new

    tr.test_spec = TEST_SPEC
    tr.path = '/test'

    tr.query

    assert tr.request
    assert_equal 'https://api.asg.northwestern.edu/test?test=test&key=TEST_KEY', tr.request

    assert tr.response
  end

  test 'redis_get_all' do
    redis = MockRedis.new

    redis.sadd 'categories', %w(test-cat-1 test-cat-2)

    redis.set 'test-cat-1', 'Test Cat 1'
    redis.set 'test-cat-2', 'Test Cat 2'

    redis.hset 'test-cat-1-1', 'id', 2
    redis.hset 'test-cat-1-1', 'result', 'pass'
    redis.hset 'test-cat-1-2', 'id', 3
    redis.hset 'test-cat-1-2', 'result', 'pass'
    redis.hset 'test-cat-2-1', 'id', 4
    redis.hset 'test-cat-2-1', 'result', 'warn'
    redis.hset 'test-cat-2-2', 'id', 5
    redis.hset 'test-cat-2-2', 'result', 'pass'

    res = TestResult.redis_get_all redis

    assert_equal 2, res.length

    assert res['test-cat-1']
    assert res['test-cat-2']

    assert res['test-cat-1'].is_a?(Hash)
    assert res['test-cat-2'].is_a?(Hash)

    assert_equal 'Test Cat 1', res['test-cat-1'][:category_name]
    assert_equal 'Test Cat 2', res['test-cat-2'][:category_name]

    assert res['test-cat-1'][:results].is_a?(Hash)
    assert res['test-cat-2'][:results].is_a?(Hash)

    assert_equal 2, res['test-cat-1'][:results].length
    assert_equal 2, res['test-cat-2'][:results].length

    assert_equal 'pass', res['test-cat-1'][:results][:worst]
    assert_equal 'warn', res['test-cat-2'][:results][:worst]

    assert_equal 2, res['test-cat-1'][:results][:tests].length
    assert_equal 2, res['test-cat-2'][:results][:tests].length
  end
end
