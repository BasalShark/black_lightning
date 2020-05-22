require 'test_helper'

class Admin::StaffingsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryBot.create(:admin, phone_number: rand(10**9..10**10).to_s)
    sign_in @user

    @staffing_jobs_attributes = {
      '0' => { id: '', name: 'High Priest',    user_name_field: '', user_id: '', _destroy: 'false' },
      '1' => { id: '', name: 'Lackey',         user_name_field: '', user_id: '', _destroy: 'false' },
    }

    @start_times = {
      '0' => { year: '2020', month: '5', day: '18', hour: '18', minute: '00' },
      '1' => { year: '2020', month: '5', day: '19', hour: '18', minute: '00' },
      '2' => { year: '2020', month: '5', day: '20', hour: '18', minute: '00' }
    }

    @end_times = {
      '0' => { hour: '21', minute: '00' },
      '1' => { hour: '21', minute: '00' },
      '2' => { hour: '21', minute: '00' }
    }

    # Turn on delayed jobs for staffings - the staffing mailer refers to the job.
    Delayed::Worker.delay_jobs = true
  end

  teardown do
    # Turn off delayed jobs back off
    Delayed::Worker.delay_jobs = false
  end

  test 'should get index' do
    FactoryBot.create_list(:staffing, 5, unstaffed_job_count: 2, staffed_job_count: 2)
    FactoryBot.create_list(:staffing, 5, staffed_job_count: 3, start_time: DateTime.now.advance(days: -5))
    get :index
    assert_response :success
    assert_not_nil assigns(:upcoming_staffings)
    assert_not_nil assigns(:archived_staffings)
  end

  test 'should get grid' do
    show_title = 'Test #&@!$@&@!(@(D???//'
    FactoryBot.create_list(:staffing, 10, staffed_job_count: 2, unstaffed_job_count: 3, show_title: show_title)

    get :grid, params: { slug: show_title.to_url }

    assert_response :success
    assert assigns(:can_sign_up)
    assert_equal assigns(:staffings).future.ids.uniq.sort, assigns(:staffings).ids.uniq.sort
    assert assigns(:staffings).any?
  end

  test 'should get archived grid' do
    show_title = 'Electric Bugaloo'
    FactoryBot.create_list(:staffing, 4, staffed_job_count: 2, unstaffed_job_count: 3, show_title: show_title, end_time: DateTime.now.advance(days: -1))

    get :grid, params: { slug: show_title.to_url, archived: 'true' }

    assert_response :success
    assert assigns(:can_sign_up)

    assert_equal assigns(:staffings).past.ids.uniq.sort, assigns(:staffings).ids.uniq.sort
    assert assigns(:staffings).any?
  end

  test 'should get archived grid when future staffings do not exist for this show' do
    show_title = 'Frost/Nixon'
    FactoryBot.create_list(:staffing, 4, staffed_job_count: 2, unstaffed_job_count: 3, show_title: show_title, end_time: DateTime.now.advance(days: -1))

    get :grid, params: { slug: show_title.to_url }

    assert_response :success
    assert assigns(:can_sign_up)

    assert_equal assigns(:staffings).past.ids.uniq.sort, assigns(:staffings).ids.uniq.sort
    assert assigns(:staffings).any?
  end

  test 'can not sign up in grid' do
    @user.update_attribute(:phone_number, nil)

    staffing = FactoryBot.create(:staffing, unstaffed_job_count: 2)
    get :grid, params: { slug: staffing.show_title.to_url }

    assert_response :success
    assert_not assigns(:can_sign_up)
    assert_match 'you need to provide a MOBILE phone number', response.body
  end

  test 'should show staffing' do
    staffing = FactoryBot.create(:staffing, unstaffed_job_count: 5)

    get :show, params: { id: staffing }

    assert_response :success
    assert assigns(:can_sign_up)
  end

  test 'cannot sign up in show without phone number' do
    @user.update_attribute(:phone_number, nil)

    staffing = FactoryBot.create(:staffing, unstaffed_job_count: 2)
    get :show, params: { id: staffing }

    assert_response :success
    assert_not assigns(:can_sign_up)
    assert_match 'you need to provide a MOBILE phone number', response.body
  end

  test 'cannot sign up in show without permission' do
    sign_out @user
    sign_in FactoryBot.create(:committee, phone_number: '11000111')

    staffing = FactoryBot.create(:staffing, unstaffed_job_count: 2)
    get :show, params: { id: staffing }

    assert_response :success
    assert_not assigns(:can_sign_up)
    assert_no_match 'you need to provide a MOBILE phone number', response.body
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create admin_staffing' do
    user = FactoryBot.create(:user)
    staffing_jobs_attributes = {
      '0' => { id: '', name: 'High Priest',    user_name_field: 'Should not matter', user_id: user.id, _destroy: 'false' },
      '1' => { id: '', name: 'Lackey',         user_name_field: '',                  user_id: '',      _destroy: 'false' },
    }

    attributes = FactoryBot.attributes_for(:staffing, staffing_jobs_attributes: staffing_jobs_attributes)

    assert_difference('Admin::Staffing.count', @start_times.count) do
      post :create, params: { admin_staffing: attributes, start_times: @start_times, end_times: @end_times }

      assert_nil flash[:error]

      # If this fails, you will have to find another way to get the corresponding url (it's called slug in the create function), or just remove this check.
      assert_redirected_to grid_admin_staffings_path(attributes[:show_title].to_url)
    end
  end

  test 'should not create with invalid staffing jobs attributes' do
    staffing_jobs_attributes = {
      '0' => { id: '', name: 'High Priest',    user_name_field: 'Finbar', user_id: '2', _destroy: 'false' },
      '1' => { id: '', name: 'Lackey',         user_name_field: 'Evil',   user_id: '',  _destroy: 'false' },
      '2' => { id: '', name: 'Dinner',         user_name_field: 'Dennis', user_id: '',  _destroy: 'false' },
      '3' => { id: '', name: 'Dungeon Master', user_name_field: '',       user_id: '',  _destroy: 'false' }
    }

    attributes = FactoryBot.attributes_for(:staffing, staffing_jobs_attributes: staffing_jobs_attributes)

    assert_no_difference('Admin::Staffing.count') do
      post :create, params: { admin_staffing: attributes, start_times: @start_times, end_times: @end_times }

      assert_equal ['There was a typo entering the name of the users Evil and Dennis. Their previous name has been restored.'], flash[:error]
    end
  end

  test 'should not create without start or end times' do
    attributes = FactoryBot.attributes_for(:staffing, staffing_jobs_attributes: @staffing_jobs_attributes)

    assert_no_difference('Admin::Staffing.count') do
      post :create, params: { admin_staffing: attributes, start_times: @start_times, end_times: {} }

      assert_equal ['You have not specified any start and end times.'], flash[:error]
    end

    flash[:error].clear

    assert_no_difference('Admin::Staffing.count') do
      post :create, params: { admin_staffing: attributes, start_times:{}, end_times: @end_times }

      assert_equal ['You have not specified any start and end times.'], flash[:error]
    end
  end

  test 'should not create without staffing jobs' do
    attributes = FactoryBot.attributes_for(:staffing, staffing_jobs_attributes: {})

    assert_no_difference('Admin::Staffing.count') do
      post :create, params: { admin_staffing: attributes, start_times: @start_times, end_times: @end_times }

      assert_equal ['You have not added any jobs.'], flash[:error]
    end
  end

  test 'should not create with invalid staffing' do
    attributes = FactoryBot.attributes_for(:staffing, show_title: nil, staffing_jobs_attributes: @staffing_jobs_attributes)

    assert_no_difference('Admin::Staffing.count') do
      post :create, params: { admin_staffing: attributes, start_times: @start_times, end_times: @end_times }

      assert_equal ['There is an issue with the form.', 'Show title must not be blank.'], flash[:error]
    end
  end

  test 'should get edit' do
    @staffing = FactoryBot.create(:staffing, unstaffed_job_count: 3)

    get :edit, params: { id: @staffing }
    assert_response :success
  end

  test 'should update staffing' do
    staffing = FactoryBot.create(:staffing, staffed_job_count: 2)
    attrs = FactoryBot.attributes_for(:staffing, staffing_jobs_attributes: @staffing_jobs_attributes)

    put :update, params: { id: staffing, admin_staffing: attrs }

    assert_redirected_to admin_staffing_path(assigns(:staffing))
  end

  test 'should not update invalid staffing' do
    staffing = FactoryBot.create(:staffing, staffed_job_count: 2)
    attrs = FactoryBot.attributes_for(:staffing, show_title: nil, staffing_jobs_attributes: @staffing_jobs_attributes)

    put :update, params: { id: staffing, admin_staffing: attrs }

    assert_response :unprocessable_entity
  end

  test 'should destroy staffing' do
    @staffing = FactoryBot.create(:staffing, staffed_job_count: 2)

    assert_difference('Admin::Staffing.count', -1) do
      assert_difference('Admin::StaffingJob.count', -2) do
        delete :destroy, params: { id: @staffing }
      end
    end

    assert_redirected_to admin_staffings_path
  end

  test 'should get sign_up_confirm' do
    job = FactoryBot.create(:unstaffed_staffing_job)

    get :sign_up_confirm, params: { id: job }

    assert_response :success
  end

  test 'should not get sign_up_confirm without phone number' do
    @user.update_attribute(:phone_number, nil)

    @staffing = FactoryBot.create(:staffing, staffed_job_count: 2)

    job = FactoryBot.create(:unstaffed_staffing_job)

    get :sign_up_confirm, params: { id: job }

    assert_equal 'You cannot sign up for staffings. Have you set a phone number?', flash[:error]
    assert_redirected_to admin_staffing_path(job.staffable)
  end

  test 'should not get sign_up_confirm without permission' do
    sign_in FactoryBot.create(:member)

    job = FactoryBot.create(:unstaffed_staffing_job)

    get :sign_up_confirm, params: { id: job }

    assert_equal 'You cannot sign up for staffings. Have you set a phone number?', flash[:error]

    assert_redirected_to admin_staffing_path(job.staffable)
  end

  test 'should put sign_up' do
    job = FactoryBot.create(:unstaffed_staffing_job)

    put :sign_up, params: { id: job }

    assert_nil flash[:error]
    admin_staffing_path(job.staffable)

    assert_equal Admin::StaffingJob.find(job.id).user_id, @user.id
  end

  test 'sign_up should fail when job is already staffed by someone else' do
    job = FactoryBot.create(:staffed_staffing_job)
    job.staffable.start_time = Time.now.advance(days: -1)

    put :sign_up, params: { id: job }

    assert_equal ['Someone else has already signed up for this slot'], flash[:error]

    assert_redirected_to admin_staffing_path(job.staffable)
  end

  test 'sign up should succeed when you are signing up for a job you are already signed up for' do
    job = FactoryBot.create(:staffed_staffing_job, user: @user)

    put :sign_up, params: { id: job }

    assert_nil flash[:error]

    assert_redirected_to admin_staffing_path(job.staffable)
  end

  test 'sign_up should fail for user without permission' do
    sign_in FactoryBot.create(:member)

    job = FactoryBot.create(:unstaffed_staffing_job)

    put :sign_up, params: { id: job }

    assert_equal ['You cannot sign up for staffings. Have you set a phone number?'], flash[:error]

    assert_redirected_to admin_staffing_path(job.staffable)
  end

  test 'sign_up should fail for user without phone number' do
    @user.update_attribute(:phone_number, nil)
    job = FactoryBot.create(:unstaffed_staffing_job)

    put :sign_up, params: { id: job }

    assert_equal ['You cannot sign up for staffings. Have you set a phone number?'], flash[:error]

    assert_redirected_to admin_staffing_path(job.staffable)
  end

  test 'sign_up should fail for job in the past' do
    staffing = FactoryBot.create(:staffing, unstaffed_job_count: 1, start_time: Time.now.advance(days: -1))
    job = staffing.staffing_jobs.first

    put :sign_up, params: { id: job }

    assert_equal ['You cannot sign up for staffings in the past. Please contact the Front of House-manager if you have staffed this shift.'], flash[:error]

    assert_redirected_to admin_staffing_path(job.staffable)
  end

  test 'guidelines' do
    get :guidelines

    assert_response :success
  end
end
