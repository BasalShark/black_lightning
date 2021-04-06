require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test 'committee can get committee' do
    get :committee
  end

  test 'non committee cannot get committee' do
    sign_in users(:member)

    get :committee
  end
end
