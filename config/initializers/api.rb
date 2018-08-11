require 'northwestern-api'

if Rails.env == 'test'
  Northwestern::API_KEY = 'TEST_KEY'
else
  Northwestern::API_KEY = ENV['NU_API_KEY']
end
