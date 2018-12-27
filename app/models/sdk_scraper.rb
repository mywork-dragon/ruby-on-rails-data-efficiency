# == Schema Information
#
# Table name: sdk_scrapers
#
#  id                       :integer          not null, primary key
#  name                     :string(191)
#  private_ip               :string(191)
#  concurrent_apk_downloads :integer
#  created_at               :datetime
#  updated_at               :datetime
#

class SdkScraper < ActiveRecord::Base
end
