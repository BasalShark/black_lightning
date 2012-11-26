class User < ActiveRecord::Base
  before_save :unify_numbers
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable

  #set our own validations
  validates :password, :presence => true, :if => lambda { new_record? || !password.nil? || !password.blank? }
  validates :email, :presence => true
  validates :phone_number, :allow_blank => true, :format => { :with => /(\+44\s?7\d{3}|07\d{3})\s?(\d{3}\s?\d{3})$/, :message => "Please enter a valid mobile number" }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :role_ids, :phone_number
  # attr_accessible :title, :body

  def name
  	"#{self.first_name} #{self.last_name}"
  end

  def unify_numbers
    return if not self.phone_number

    self.phone_number = phone_number.gsub(/\s/, '')

    if self.phone_number[0] == '0' then
      self.phone_number[0] = '+44'
    end
  end
end
