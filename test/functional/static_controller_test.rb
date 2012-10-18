require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    
    assert_select "h1", "Welcome to Project BlackLightning"
  end

  test "should get about" do
    get :about
    assert_response :success
  end
end
