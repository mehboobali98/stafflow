require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "approve_leave_information" do
    mail = UserMailer.approve_leave_information
    assert_equal "Approve leave information", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
