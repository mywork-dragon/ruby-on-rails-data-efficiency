# == Schema Information
#
# Table name: fb_activity_exceptions
#
#  id                 :integer          not null, primary key
#  fb_account_id      :integer
#  error              :text(65535)
#  backtrace          :text(65535)
#  created_at         :datetime
#  updated_at         :datetime
#  fb_activity_job_id :integer
#

class FbActivityException < ActiveRecord::Base
end
