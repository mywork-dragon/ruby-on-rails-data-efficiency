class AndroidSdk < ActiveRecord::Base

	belongs_to :sdk_company
  has_many :sdk_packages

  has_many :android_sdks_apk_snapshots
  has_many :apk_snapshots, through: :android_sdks_apk_snapshots

  attr_accessor :first_seen
  attr_accessor :last_seen

  def get_favicon
    if self.favicon.nil?
      host = URI(self.website).host
      return "https://www.google.com/s2/favicons?domain=#{host}"
    else
      return self.favicon
    end
  end

  def get_current_apps
    snaps = self.apk_snapshots.select(:id).map(&:id)
    AndroidApp.where(newest_apk_snapshot_id: snaps)
  end

end
