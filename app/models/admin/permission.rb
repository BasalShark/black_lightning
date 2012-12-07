class Admin::Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  attr_accessible :action, :subject_class

  def self.update_permission(role, subject_class, actions)
    existing_permissions = role.permissions.where({ :subject_class => subject_class })

    if existing_permissions then
      existing_permissions.each do |perm|
        if not actions.include? perm.action then
          #The role no longer has this permission. Get rid
          role.permissions.delete(perm)
        end
      end
    end

    actions.each do |action|
      if (not existing_permissions) or (not existing_permissions.find_by_action(action)) then
        #Try to add the role to the existing permission
        if permission = Admin::Permission.where({ :action => action, :subject_class => subject_class }).first;
          permission.roles << role
        else
          permission = Admin::Permission.new
          permission.action = action[0]
          permission.subject_class = subject_class
          permission.roles << role
        end

        permission.save
      end
    end

    role.save
  end
end
