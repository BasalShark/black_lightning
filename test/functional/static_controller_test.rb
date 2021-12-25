require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  test 'should get home' do
    FactoryBot.create_list(:show, 10)

    get :home
    assert_response :success

    get :home, params: { mobile: 'true' }
    assert_response :success
    assert session[:mobile_param], 'true'
  end

  test 'should get contact' do
    get :show, params: { page: 'contact' }
    assert_response :success
  end

  test 'should get 404 when navigating to nonexistent page' do
    get :show, params: { page: 'pineapples_and_the_hexagon_a_memoir' }
    assert_response 404
  end

  test 'should get privacy policy' do
    get :show, params: { page: 'privacy_policy' }
    assert_response :success
  end
end
