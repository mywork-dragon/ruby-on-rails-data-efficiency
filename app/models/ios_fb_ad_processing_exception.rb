# == Schema Information
#
# Table name: ios_fb_ad_processing_exceptions
#
#  id           :integer          not null, primary key
#  ios_fb_ad_id :integer
#  error        :text(65535)
#  backtrace    :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#

class IosFbAdProcessingException < ActiveRecord::Base
  belongs_to :ios_fb_ad
end
