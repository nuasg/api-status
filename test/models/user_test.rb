require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'admin' do
    User.create(username: 'test1', admin: false)
    User.create(username: 'test2', admin: true)
    User.create(username: 'test3', admin: true)

    admins = User.admins

    assert admins.include?(User.find_by(username: 'test2'))
    assert admins.include?(User.find_by(username: 'test3'))

    assert_equal 2, admins.length
  end
end
