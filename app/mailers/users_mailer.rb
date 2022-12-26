class UsersMailer < ApplicationMailer
  # Used for render_markdown and render_plain in the views
  helper :md

  def welcome_email(user)
    @user = user

    @subject = 'Welcome to Bedlam Theatre'
    @editable_block = Admin::EditableBlock.find_by_name('Email - Welcome Email')

    mail(to: @user.email, subject: @subject)
  end
end
