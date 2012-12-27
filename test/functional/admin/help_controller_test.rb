require 'test_helper'

class Admin::HelpControllerTest < ActionController::TestCase
  setup do
    sign_in FactoryGirl.create(:admin)
  end

  test "should get kramdown" do
    get :kramdown
    assert_response :success
  end

end
