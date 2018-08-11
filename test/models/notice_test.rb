require 'test_helper'

class NoticeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'deactivate' do
    x = Notice.create(title: 'Test Notice', content: 'Test Notice Content', active: true, deactivated: nil, auto: false, severity: 'warning')

    assert x.active

    x.deactivate

    assert_not x.active
    assert_not x.changed?

    assert x.deactivated
  end

  test 'active auto notice' do
    Notice.create(title: 'Test Notice', content: 'Test Notice Content', active: true, deactivated: nil, auto: false, severity: 'warning')

    assert_not Notice.has_active_auto_notice?

    y = Notice.create(title: 'Test Notice 2', content: 'Test Notice 2 Content', active: true, deactivated: nil, auto: true, severity: 'warning')

    assert Notice.has_active_auto_notice?

    y.destroy

    assert_not Notice.has_active_auto_notice?

    Notice.create(title: 'Test Notice', content: 'Test Notice Content', active: false, deactivated: nil, auto: true, severity: 'warning')

    assert_not Notice.has_active_auto_notice?
  end
end
