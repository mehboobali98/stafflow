require 'test_helper'

class LeaveTypesControllerTest < ActionDispatch::IntegrationTest
  test "should get resources" do
    get leave_types_resources_url
    assert_response :success
  end

end
