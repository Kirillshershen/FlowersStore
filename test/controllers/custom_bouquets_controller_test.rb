require "test_helper"

class CustomBouquetsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get custom_bouquets_new_url
    assert_response :success
  end

  test "should get create" do
    get custom_bouquets_create_url
    assert_response :success
  end
end
