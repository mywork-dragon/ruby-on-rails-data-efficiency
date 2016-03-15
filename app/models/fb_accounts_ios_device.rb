class FbAccountsIosDevice < ActiveRecord::Base
  belongs_to :fb_account
  belongs_to :ios_device
end
