# == Schema Information
#
# Table name: github_accounts
#
#  id               :integer          not null, primary key
#  username         :string(191)
#  email            :string(191)
#  password         :string(191)
#  application_name :string(191)
#  homepage_url     :string(191)
#  callback_url     :string(191)
#  client_id        :string(191)
#  client_secret    :string(191)
#  last_used        :datetime
#  created_at       :datetime
#  updated_at       :datetime
#

class GithubAccount < ActiveRecord::Base
end
