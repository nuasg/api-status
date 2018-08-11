require 'test_helper'

class RunTestsJobTest < ActiveJob::TestCase
  TESTS = {
      '/test/1' => {
          category_name: 'Test 1',
          tests: [
              {
                  :name => 'Test 1-1',
                  :params => [],
                  :count => 'many',
                  :expect => {
                      :symbol => String,
                      :name => String
                  }
              },
              {
                  :name => 'Test 1-2',
                  :params => [
                      %w(test test)
                  ],
                  :count => 'many',
                  :expect => {
                      :symbol => String,
                      :name => String
                  }
              },
              {
                  :name => 'Test 1-3',
                  :params => [
                      %w(school JOUR)
                  ],
                  :count => 'many',
                  :expect => {
                      :symbol => String,
                      :name => String
                  }
              }
          ]
      },
      '/test/2' => {
          category_name: 'Test 2',
          tests: [
              {
                  :name => 'Test 2-1',
                  :params => [
                      ['instructor', 7136]
                  ],
                  :count => 2,
                  :expect => {
                      :id => Integer,
                      :title => String,
                      :term => String
                  }
              },
              {
                  :name => 'Test 2-2',
                  :params => [
                      ['id', 150763]
                  ],
                  :count => 2,
                  :expect => {
                      :id => Integer,
                      :title => String,
                      :term => String
                  }
              },
              {
                  :name => 'Test 2-3',
                  :params => [
                      ['id', 150763],
                      ['id', 165749]
                  ],
                  :count => 2,
                  :expect => {
                      :id => Integer,
                      :title => String,
                      :term => String,
                      :instructor => String
                  }
              },
              {
                  :name => 'Test 2-4',
                  :params => [
                      ['term', 4720],
                      ['room', 184]
                  ],
                  :count => 2,
                  :expect => {
                      :id => Integer,
                      :title => String,
                      :term => String
                  }
              }
          ]
      }
  }

  test 'data_age' do
    job = RunTestsJob.new

    redis = MockRedis.new

    Timecop.freeze(Date.new(2016, 11, 1)) do
      job.test_data_age redis

      assert_equal '2018 Fall', redis.hget('/data/age', 'string')
      assert_equal 'pass', redis.hget('/data/age', 'result')
    end

    redis.flushall

    Timecop.freeze(Date.new(2018, 8, 11)) do
      job.test_data_age redis

      assert_equal 'warn', redis.hget('/data/age', 'result')
    end

    redis.flushall

    Timecop.freeze(Date.new(2019, 7, 24)) do
      job.test_data_age redis

      assert_equal 'fail', redis.hget('/data/age', 'result')
    end
  end

  test 'run job' do
    redis = MockRedis.new

    RunTestsJob.perform_now false, redis, TESTS


  end
end
