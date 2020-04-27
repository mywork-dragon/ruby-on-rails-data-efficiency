class AppPermissionsHotstoreImportWorker
  include Sidekiq::Worker
  include Utils::Workers
  sidekiq_options queue: :hot_store_application_import, retry: 2

  attr_reader :importer

  def initialize
    @importer = AppPermissionsHotstoreImporter.new
  end

  def perform(app_ids)
    app_ids.each { |id| importer.import_ios(id) }
  end

  def queue_ios_apps
    IosApp
      .where.not(:display_type => IosApp.display_types[:not_ios])
      .where.not(newest_ipa_snapshot_id: nil)
      .pluck(:id).each_slice(100) do |ids|
        delegate_perform(self.class, ids)
    end
  end

end
