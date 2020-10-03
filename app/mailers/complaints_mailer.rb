class ComplaintsMailer < ActionMailer::Base
  default from: 'Bedlam Theatre <no-reply@bedlamtheatre.co.uk>'

  def new_complaint(complaint)
    @complaint = complaint

    @creation_time_string = l(@complaint.created_at, format: :longy)

    receiver = 'welfare@bedlamtheatre.co.uk'

    mail(to: receiver, subject: "New Complaint Submitted on #{@creation_time_string}")
  end
end
