class UserMailer < ActionMailer::Base
  default from: "MightySignal <support@mightysignal.com>"
  
  def invite_email(user)
    @user = user
    @account = user.account
    mail(to: user.email, subject: "You've been invited to use MightySignal!")
  end  
end
