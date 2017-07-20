##
# Defines the abilities for each user. See CanCan documentation for more details.
#
# It reads the Admin::Permission model in the database to find if a user can do something.
#
# PLEASE, PLEASE, make sure that
#
#   if user.has_role? :admin
#     can :manage, :all
#   end
#
# is included as the last thing in the initialize method.
# This ensures that users with the admin role will _always_ have permission to do everything.
##

class Ability
  include CanCan::Ability

  # Define the permissions for a user.
  def initialize(user)
    # If you can approve something, you can also reject it
    alias_action :reject, to: :approve

    # Alias grid to read
    alias_action :grid, to: :read

    alias_action :guidelines, to: :read

    if user

      # All users can manage themselves.
      can :manage, User, id: user.id
      cannot :assign_roles, User
      cannot :read, User

      can do |action, subject_class, subject|
        allow = false

        user.roles.each do |role|
          if subject_class == Symbol
            subject_class = subject
          end

          if role.permissions.where(action: [aliases_for_action(action), :manage].flatten, subject_class: subject_class).any?
            allow = true
          end
        end

        next allow
      end

      can :read, Admin::Proposals::Proposal do |proposal|
        if Time.now < proposal.call.deadline
          # Before the deadline, all users can only see proposals that they
          # are part of.
          next (proposal.users.include?(user) || user.has_role?(:proposal_viewer))
        elsif !proposal.call.archived
          # After the deadline:
          if user.has_role?(:committee) || user.has_role?(:subcommittee) || user.has_role?(:proposal_viewer)
            # Committee can see all proposals.
            next true
          else
            # Other users can only see proposals that they are part of, or
            # that have been approved.
            next (proposal.users.include?(user) || proposal.approved == true)
          end
        else
          # for archived calls, only approved proposals may be seen:
          next (proposal.approved == true)
        end
      end

      can :create, Admin::Proposals::Proposal
      can :update, Admin::Proposals::Proposal do |proposal|
        (proposal.users.include? user) && (proposal.call.deadline > Time.now) && (proposal.call.open)
      end

      can :read, Admin::Questionnaires::Questionnaire do |questionnaire|
        (questionnaire.users.include? user)
      end

      can :answer, Admin::Questionnaires::Questionnaire do |questionnaire|
        (questionnaire.users.include? user)
      end

      can :read, Admin::Feedback do |feedback|
        feedback.show.users.all.include? user
      end

      can :update, Show do |show|
        show.team_members.where("(position = 'Director' OR position = 'Producer') AND user_id = ?", user.id).count > 0
      end

      can :read, Admin::Debt do |debt|
        debt.id == user.id
      end

      can :manage, Admin::Debt if user.has_role? :committee

      #####################
      # ADMIN PERMISSIONS #
      ##############################################
      # (Leave at the bottom to ensure precedence) #
      ##############################################
      if user.has_role? :admin
        can :manage, :all
      end

    else

      can :read, News, show_public: true

    end
  end
end
