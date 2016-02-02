class FbActivity < ActiveRecord::Base
  belongs_to :fb_account
  belongs_to :fb_activity_job
end
