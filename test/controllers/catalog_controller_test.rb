require "test_helper"

class CatalogControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get catalog_index_url
    assert_response :success
  end

  test "should get show" do
    get catalog_show_url
    assert_response :success
  end
end
