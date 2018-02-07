class UserMailerPreview < ActionMailer::Preview
  def invite_email
    a = Account.find_or_create_by!(name: 'junk')
    u = User.find_by_email('junk@mightysignal.com') || User.create!(email: 'junk@mightysignal.com', password: 'blank', account: a)
    UserMailer.invite_email(u)
  end
end
