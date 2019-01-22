# == Schema Information
#
# Table name: oauth_users
#
#  id            :integer          not null, primary key
#  provider      :string(191)
#  uid           :string(191)
#  name          :string(191)
#  oauth_token   :string(191)
#  refresh_token :string(191)
#  instance_url  :string(191)
#  created_at    :datetime
#  updated_at    :datetime
#  email         :string(191)
#

class OauthUser < ActiveRecord::Base

  def self.from_omniauth(auth)
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
