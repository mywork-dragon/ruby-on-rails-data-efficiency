class OauthUser < ActiveRecord::Base

  def self.from_omniauth(auth)
    puts "auth: #{auth}"
    
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.instance_url = auth.credentials.instance_url
      user.email = auth.extra.email
      user.save!
    end
  end

end
