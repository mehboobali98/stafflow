require 'test_helper'

class DesignationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get designations_new_url
    assert_response :success
  end

end
