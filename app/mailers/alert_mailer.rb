class AlertMailer < ApplicationMailer
  default from: 'alerts@api.asg.northwestern.edu'

  def alert_email
    @failures = params[:failures]
    @time = params[:timestamp]
    @ids = params[:ids]

    mail(to: params[:to], subject: "Course Data API Test Failure Summary")
  end
end
