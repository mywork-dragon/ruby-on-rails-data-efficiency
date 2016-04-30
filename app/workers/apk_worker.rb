module ApkWorker

  def perform(apk_snapshot_job_id, bid, app_id, google_account_id=nil, check_version=true)
    @apk_ss = nil
    @apk_ss_job = nil
    @android_app = nil
    download_apk(apk_snapshot_job_id, bid, app_id, google_account_id: google_account_id, check_version: check_version)
  end
  
  # The path of the apk_file on the box
  def apk_file_path
    if Rails.env.production?
      file_path = "/mnt/apk_files/"
    elsif Rails.env.development?
      file_path = "../apk_files/"
    end
    file_path
  end

  # Download the APK
  # @author Jason Lew
  def download_apk(apk_snapshot_job_id, bid, android_app_id, google_account_id: nil, check_version: true)
    tries ||= retries + 1

    @apk_ss_job = ApkSnapshotJob.find_by_id(apk_snapshot_job_id)
    @android_app = AndroidApp.find(android_app_id)

    aa = AndroidApp.find_by_id(android_app_id)
    raise BlankAndroidApp.new(android_app_id: android_app_id) if aa.blank?

    app_identifier = aa.app_identifier
    raise BlankAppIdentifier.new(android_app_id: android_app_id) if app_identifier.blank?

    if @apk_ss.nil?
      @apk_ss = ApkSnapshot.create!(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id)
    else
      raise_early_stop(@apk_ss)
      @apk_ss.try += 1
      @apk_ss.save!
    end
    @try_count = @apk_ss.try

    raise BlankSnapId if @apk_ss.id.blank?

    if check_version && !new_version?(android_app_id)
      @apk_ss.status = :unchanged_version
      @apk_ss.save!
      return "The version hasn't changed."
    end

    google_account = google_account_id ? GoogleAccount.find(google_account_id) : a_google_account
    
    mp = choose_proxy

    dl_start_time = Time.now

    # configure download
    ApkDownloader.configure do |config|
      config.email = google_account.email
      config.password = google_account.password
      config.android_id = google_account.android_identifier
    end

    file_name = apk_file_path + app_identifier + "_#{@apk_ss.id}_#{@try_count}" + ".apk"

    begin
      dl = ApkDownloader.download!(app_identifier, file_name, google_account.android_identifier, google_account.email, google_account.password, mp.private_ip, 8888, google_account.user_agent)
    rescue ApkDownloader::EmptyApp, ApkDownloader::EmptyRecursiveApkFetch => e
      @apk_ss.status = :failure
      @apk_ss.save!
      raise
    rescue ApkDownloader::Response403, ApkDownloader::Response404 => e
      @apk_ss.status = e.status if e.status
      @apk_ss.save!
      aa.display_type = e.display_type if e.display_type
      aa.save!
      raise
    rescue ApkDownloader::Response500
      google_account.flags += 1
      google_account.save!
      raise
    rescue ApkDownloader::NoApkDataUrl, ApkDownloader::NoApkDataCookie => e
      @apk_ss.status = :no_response
      @apk_ss.save!
      raise
    else
      google_account.flags = 0
      google_account.save!

      set_google_account_in_use_false(google_account)
      dl
    end
      
  rescue => e
    set_google_account_in_use_false(google_account)

    raise if @apk_ss.nil?

    message_split = e.message.to_s.split("| status_code:")
    status_code = message_split[1].to_s.strip.to_i
    message = message_split[0].to_s.strip.encode('utf-8')
    backtrace = e.backtrace.map{ |x| x.encode('utf-8')}
    apk_ss_id = @apk_ss.blank? ? nil : @apk_ss.id
    google_account_id = google_account.present? ? google_account.id : nil

    ApkSnapshotException.create!(apk_snapshot_id: apk_ss_id, name: message, backtrace: backtrace, try: @try_count, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: google_account_id, status_code: status_code)

    if message.include? "Couldn't connect to server"
      @apk_ss.status = :could_not_connect
    elsif message.include?("execution expired") || message.include?("Timeout was reached")
      @apk_ss.status = :timeout
    elsif message.include? "Mysql2::Error: Deadlock found when trying to get lock"
      @apk_ss.status = :deadlock
    end

    @apk_ss.last_device = google_account.device.to_sym unless google_account.blank?
    @apk_ss.save!

    File.delete(file_name) if file_name && File.exist?(file_name)

    retry unless (tries -= 1).zero?

    raise
  else

    dl_end_time = Time.now()
    dl_time = (dl_end_time - dl_start_time).to_s

    google_account.flags = 0
    set_google_account_in_use_false(google_account) # this saves it too
    
    # update snapshot with new data
    @apk_ss.google_account_id = google_account.id
    @apk_ss.last_device = google_account.device.to_sym
    @apk_ss.download_time = dl_time
    @apk_ss.status = :success

    # new way -- jlew
    af = ApkFile.new
    zip_and_save_result = zip_and_save(apk_file: af, apk_file_path: file_name, android_app_identifier: aa.app_identifier)

    # rename file with version
    version_name = zip_and_save_result[:version_name]
    version_code = zip_and_save_result[:version_code]

    puts "version_name: #{version_name}"
    puts "version_code: #{version_code}"

    @apk_ss.version = version_name if version_name.present?
    @apk_ss.version_code = version_code if version_code.present?

    @apk_ss.apk_file = af

    # debugging
    # @apk_ss.auth_token = ''
    @apk_ss.last_updated = DateTime.now
    @apk_ss.save!

    # save snapshot to app
    aa.save!

    File.delete(file_name) if file_name && File.exist?(file_name)

    classify_if_necessary(@apk_ss.id)
  end

  # Scrape app page
  # @author Jason Lew
  # @param android_app_id
  # @return version, attributes
  def scrape_version(android_app_id)
    tries ||= 3

    android_app = AndroidApp.find_by_id(android_app_id)
    return {} if android_app.nil?

    android_app_identifier = android_app.app_identifier
    return {} if android_app_identifier.blank?

    a = GooglePlayService.attributes(android_app_identifier)
    version = a[:version]
    return {attributes: a} if version.blank?

    return {attributes: a} if version.strip.blank? || version.match(/varies with device/i)

    price = a[:price]
    return {attributes: a} if price.respond_to?(:>) && price > 0
    {version: version, attributes: a}

  rescue => e
    ApkSnapshotScrapeException.create!(
      apk_snapshot_job: @apk_ss_job,
      android_app: @android_app,
      error: e.message,
      backtrace: e.backtrace
      )
    retry unless (tries -= 1).zero?
    raise
  end

  # Is the current version a new version?
  # If not, it'll update the good_as_of_date
  # @author Jason Lew
  def new_version?(android_app_id)
    version_and_attributes = scrape_version(android_app_id)
    return true if version_and_attributes.blank?
    scraped_version = version_and_attributes[:version]
    attributes = version_and_attributes[:attributes]

    if scraped_version
      last_apk_ss = ApkSnapshot.where(android_app_id: android_app_id, status: ApkSnapshot.statuses[:success]).order("created_at DESC").first
      return true if last_apk_ss.blank?
      puts "android_app_id: #{android_app_id} | last_version: #{last_apk_ss.version} | scraped_version: #{scraped_version}"
      if last_apk_ss.version == scraped_version
        last_apk_ss.good_as_of_date = DateTime.now
        last_apk_ss.save!

       ApkSnapshotScrapeFailure.create!(
        apk_snapshot_job: @apk_ss_job,
        android_app: @android_app,
        reason: :unchanged_version,
        scrape_content: attributes.to_json,
        version: scraped_version
        )

        return false
      end
    end

    true
  end

  def a_google_account
    ga = nil

    GoogleAccount.transaction do 
      ga = choose_google_account(try: @try_count)  # implemented by specific worker
      raise CouldNotFindGoogleAccount if ga.blank?
      ga.in_use = true;
      ga.save!
    end

    @apk_ss.google_account_id = ga.id
    @apk_ss.save!

    ga
  end

  def set_google_account_in_use_false(ga)
    return nil if ga.blank?

    GoogleAccount.transaction do 
      ga.in_use = false
      ga.save!
    end

    ga
  end

  def choose_proxy
    mp = MicroProxy.select(:private_ip).sample
    @apk_ss.micro_proxy_id = mp.id
    @apk_ss.save!
    mp
  end

  # Given an APK, unzip it, remove multimedia files, and zip it up again
  # @param apk_file An instance of the ApkFile model
  # @param apk_file_path The path to the APK on disk
  # @note THIS DOES NOT WORK
  def zip_and_save_with_blocks(apk_file:, apk_file_path:, android_app_identifier:)
    ret = {}
    Zipper.unzip(apk_file_path) do |unzipped_path|

      versions = ApkVersionGetter.versions(unzipped_path)
      ret.merge!(versions)

      FileRemover.remove_multimedia_files(unzipped_path)

      Zipper.zip(unzipped_path) do |zipped_path|
        apk_file.zip = File.open(zipped_path)
        apk_file.zip_file_name = "#{android_app_identifier}.zip"
        apk_file.save!
        return ret
      end
    end
  end

    # Given an APK, unzip it, remove multimedia files, and zip it up again
  # @param apk_file An instance of the ApkFile model
  # @param apk_file_path The path to the APK on disk
  def zip_and_save(apk_file:, apk_file_path:, android_app_identifier:)
    ret = {}

    zipper = Zipper.new

    zipper.unzip(apk_file_path)
    unzipped_path = zipper.unzipped_path

    versions = ApkVersionGetter.versions(unzipped_path)
    ret.merge!(versions)

    FileRemover.remove_multimedia_files(unzipped_path)

    zipper.zip(unzipped_path)
    zipped_path = zipper.zipped_path

    apk_file.zip = File.open(zipped_path)
    apk_file.zip_file_name = "#{android_app_identifier}.zip"
    apk_file.save!
    
    zipper.remove_all

    ret
  end

  class BlankAndroidApp < StandardError
    attr_accessor :android_app_id
    def initialize(message = "The AndroidApp is blank.", android_app_id: nil)
      @android_app_id = android_app_id
      super("The AndroidApp with id #{@android_app_id} is blank.")
    end
  end

  class EarlyStop < StandardError
    def initialize(message = "The error is likely unrecoverable, so we stopped retrying early.")
      super
    end
  end

  class BlankSnapId < StandardError
    def initialize(message = "The ApkSnapshot has a blank id.")
      super
    end
  end

  class CouldNotFindGoogleAccount < StandardError
    def initialize(message = "The query did not return a GoogleAccount.")
      super
    end
  end

  class BlankAppIdentifier < StandardError
    attr_accessor :android_app_id
    def initialize(message = "The AndroidApp has a blank app_identifier.", android_app_id: nil)
      @android_app_id = android_app_id
      super("The AndroidApp with id #{android_app_id} has a blank app_identifier.")
    end
  end

  class ScrapePaidApp < StandardError
    def initialize(message = "It's a paid app.")
      super
    end
  end

end