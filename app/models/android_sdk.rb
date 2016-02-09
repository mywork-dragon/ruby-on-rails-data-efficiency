class AndroidSdk < ActiveRecord::Base

	belongs_to :sdk_company
  has_many :sdk_packages

  has_many :android_sdks_apk_snapshots
  has_many :apk_snapshots, through: :android_sdks_apk_snapshots

  attr_accessor :first_seen
  attr_accessor :last_seen

  def get_favicon
    if self.favicon.nil?
      return nil if self.website.blank?
      host = URI(self.website).host
      return "https://www.google.com/s2/favicons?domain=#{host}"
    else
      return self.favicon
    end
  end

  def get_current_apps
    snaps = self.apk_snapshots.select(:id).map(&:id)
    AndroidApp.where(newest_apk_snapshot_id: snaps).where.not(display_type: AndroidApp.display_types[:taken_down])
  end

  def test
    snaps = self.apk_snapshots.select(:id).map(&:id)
    AndroidApp.where(newest_apk_snapshot_id: snaps).count
  end

  def get_current_apps_faster
    AndroidApp.where(id: self.ipa_snapshots.select('ios_app_id, max(good_as_of_date) as good_as_of_date').where(scan_status: 1).group(:ios_app_id).pluck(:ios_app_id))
  end

end
