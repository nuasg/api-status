class AlertMailer < ApplicationMailer
  default to: -> {User.where(admin: true).pluck(:email) << 'asg-technology@u.northwestern.edu'},
          from: 'alerts@api.asg.northwestern.edu',
          subject: 'Course Data API Test Failure Summary'

  def alert_email
    @failures = params[:failures]
    @timestamp = params[:timestamp]

    mail
  end
end
