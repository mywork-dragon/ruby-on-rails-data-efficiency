# == Schema Information
#
# Table name: ios_email_accounts
#
#  id         :integer          not null, primary key
#  email      :string(191)
#  password   :string(191)
#  flagged    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class IosEmailAccount < ActiveRecord::Base
end
