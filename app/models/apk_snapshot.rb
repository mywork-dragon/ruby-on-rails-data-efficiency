class ApkSnapshot < ActiveRecord::Base

  belongs_to :google_account
  belongs_to :android_app
  belongs_to :apk_snapshot_job
  belongs_to :micro_proxy

  has_many :android_sdk_packages_apk_snapshots
  has_many :android_sdk_packages, through: :android_sdk_packages_apk_snapshots

  has_many :android_sdk_companies_apk_snapshots
	has_many :android_sdk_companies, through: :android_sdk_companies_apk_snapshots

  has_many :sdk_packages_apk_snapshots
  has_many :sdk_packages, through: :sdk_packages_apk_snapshots

  has_many :android_sdks_apk_snapshots
  has_many :android_sdks, through: :android_sdks_apk_snapshots

  belongs_to :apk_file

	enum status: [:failure, :success, :no_response, :forbidden, :taken_down, :could_not_connect, :timeout, :deadlock, :bad_device, :out_of_country, :bad_carrier, :not_found]
  enum scan_status: [:scan_failure, :scan_success]

  def first_seen
    app_released :first
  end

  def last_seen
    app_released :last
  end

  private

  def app_released(first_last)
    a = {version: self.version}
    b = ['created_at < ?',self.created_at]
    [a,b].each do |x|
      s = self.android_app.android_app_snapshots.where(x).send(first_last)
      return s.released if s
    end
  end

end