class UserMailer < ActionMailer::Base
  default from: "MightySignal <support@mightysignal.com>"
  
  def invite_email(user)
    @user = user
    @account = user.account
    @token = user.generate_auth_token
    @link_url = "https://mightysignal.com/app/app#/login?token=#{@token}"
    mail(to: user.email, subject: "You've been invited to use MightySignal!")
  end  
end
