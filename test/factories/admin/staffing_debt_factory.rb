FactoryGirl.define do
  factory :staffing_debt, class: Admin::StaffingDebt do
    association :user, factory: :member
    association :show, factory: :show
    due_by Date.today + 1
  end

  factory :overdue_staffing_debt, parent: :staffing_debt do
    due_by Date.today - 1
  end

end