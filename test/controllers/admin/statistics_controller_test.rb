require "test_helper"

class Admin::StatisticsControllerTest < ActionDispatch::IntegrationTest
  test "should get sales" do
    get admin_statistics_sales_url
    assert_response :success
  end
end
