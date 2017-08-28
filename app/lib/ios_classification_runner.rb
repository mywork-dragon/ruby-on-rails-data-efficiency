class IosClassificationRunner

  attr_accessor :classifier

  def initialize(ipa_snapshot_id, options={})
    @ipa_snapshot_id = ipa_snapshot_id
    @options = options
    @classifier = IosSdkClassifier.new(
      @ipa_snapshot_id,
      @options[:classification_options] || {}
    )
  end

  def run
    update_scan_status(:scanning) unless @options[:disable_status_updates]
    classify
    update_scan_status(:scanned) unless @options[:disable_status_updates]
    log_activities unless @options[:disable_activity_logging]
    log_result('ios_scan_success') if @options[:log_scan_result]
  rescue
    log_result('ios_scan_failure') if @options[:log_scan_result]
    update_scan_status(:failed)
    raise
  ensure
    snapshot = IpaSnapshot.find(@ipa_snapshot_id)
    IosApp.find(snapshot.ios_app_id).update_newest_ipa_snapshot
  end

  def update_scan_status(status)
    IpaSnapshot.find(@ipa_snapshot_id).update(scan_status: status)
  end

  def classify
    @classifier.classify
    @classifier.save!
  end

  def log_result(event_name)
    snapshot = IpaSnapshot.includes(:ios_app, :app_store).find(@ipa_snapshot_id)
    app = snapshot.ios_app
    store = snapshot.app_store
    RedshiftLogger.new(records: [{
      name: event_name,
      ios_app_id: app.id,
      ios_app_identifier: app.app_identifier,
      ios_app_store: store.country_code,
      ios_scan_type: @options[:scan_type]
    }]).send!
  rescue => e
    Bugsnag.notify(e)
  end

  def log_activities
    snapshot = IpaSnapshot.find(@ipa_snapshot_id)
    ActivityWorker.new.perform(:log_ios_sdks, snapshot.ios_app_id)
  rescue => e
    Bugsnag.notify(e)
  end
end
