# == Schema Information
#
# Table name: admin_debt_notifications
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  sent_on           :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  notification_type :integer
#
class Admin::DebtNotification < ApplicationRecord
  enum notification_type: %i[initial_notification reminder]
  belongs_to :user

  DISABLED_PERMISSIONS = %w[create update delete manage].freeze

  def self.search_for(first_name, last_name)
    user_ids = User.search_for(first_name, last_name).ids
    notifications = self.where(user_id: user_ids)

    return notifications
  end
end
