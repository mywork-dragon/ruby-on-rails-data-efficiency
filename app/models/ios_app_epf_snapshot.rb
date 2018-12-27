# == Schema Information
#
# Table name: ios_app_epf_snapshots
#
#  id                  :integer          not null, primary key
#  export_date         :integer
#  application_id      :integer
#  title               :text(65535)
#  recommended_age     :string(191)
#  artist_name         :text(65535)
#  seller_name         :string(191)
#  company_url         :text(65535)
#  support_url         :text(65535)
#  view_url            :text(65535)
#  artwork_url_large   :text(65535)
#  artwork_url_small   :string(191)
#  itunes_release_date :date
#  copyright           :text(65535)
#  description         :text(65535)
#  version             :string(191)
#  itunes_version      :string(191)
#  download_size       :integer
#  epf_full_feed_id    :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class IosAppEpfSnapshot < ActiveRecord::Base

  belongs_to :epf_full_feed

end
