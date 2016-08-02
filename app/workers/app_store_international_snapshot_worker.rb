class AppStoreInternationalSnapshotWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: 1, queue: :default

  class UnrecognizedFormat < RuntimeError
    def initialize(json)
      super(json.to_json)
    end
  end

  def perform(ios_app_current_snapshot_job_id, ios_app_ids, app_store_id)
    @ios_app_current_snapshot_job_id = ios_app_current_snapshot_job_id
    @ios_app_ids = ios_app_ids
    @app_store = AppStore.find(app_store_id)
    @bulk_store = AppStoreHelper::BulkStore.new(
      app_store_id: @app_store.id,
      ios_app_current_snapshot_job_id: @ios_app_current_snapshot_job_id
    )
    get_and_store_apps
  end

  def get_and_store_apps
    ios_apps = IosApp.where(id: @ios_app_ids)
    ios_apps.each_slice(100) do |apps|
      identifier_to_app_map = apps.reduce({}) do |memo, app|
        memo[app.app_identifier] = app if app.app_identifier
        memo
      end
      res = ItunesApi.batch_lookup(identifier_to_app_map.keys, @app_store.country_code.downcase)
      res['results'].each { |app_json| add_app(app_json, identifier_to_app_map) }
    end
    bulk_save
  end

  def bulk_save
    @bulk_store.save
  end

  def add_app(app_json, identifier_to_app_map)
    extractor = AppStoreHelper::ExtractorJson.new(app_json)
    ios_app = identifier_to_app_map[extractor.app_identifier]
    extractor.verify_ios!
    @bulk_store.add_data(ios_app, app_json)
  rescue AppStoreHelper::ExtractorJson::NotIosApp
    if ios_app
      ios_app.update!(
        display_type: IosApp.display_types[:not_ios],
        app_store_available: false
      )
    elsif extractor.alternate_identifier
      IosApp
        .find_by_app_identifier!(extractor.alternate_identifier)
        .update!(display_type: IosApp.display_types[:not_ios])
    else
      raise UnrecognizedFormat, app_json
    end
  end

  class << self

    def test
      app_identifiers = [521572360, 519683325, 523405208, 860586071, 898127878, 818245884, 968618875, 902896005, 856607616, 869174355, 892604595, 870097693, 889786499, 889784804, 583713992, 381071573, 920143191, 952142692, 944763883, 899890163, 902586570, 556744011, 559645118, 934449961, 365773474, 447830169, 787320906, 824027414, 717314200, 569626940, 338961856, 868005801, 868757368, 905837412, 904914140, 852040884, 504167467, 948237518, 841465004, 959272644, 778572135, 957204324, 731936387, 877215853, 902951376, 869225531, 723261249, 702173904, 693387755, 842525769, 858613927, 821578443, 573537183, 814994783, 554726752, 427242564, 942064355, 905099592, 920161006, 964784701, 962133182, 970892126, 807323207, 885397079, 910553513, 924729684, 912657379, 950268624, 973817843, 969003660, 406680074, 923570633, 256459711, 407392030, 906477179, 282612548, 965353795, 285692706, 342527639, 785413369, 969563468, 542355130, 569266174, 354604876, 819404902, 992950403, 985655033, 993767164, 561183792, 976739429, 984458958, 998486927, 987241847, 968351471, 933476303, 993102364, 985155815, 993474068, 981425767, 986297594, 970277569, 973313037, 730295774, 972085273, 960358457, 983345378, 983702883, 984671254, 995683857, 990710181, 990041218, 977008778, 993580625, 995109407, 983404497, 992595501, 979119085, 982138762, 979652808, 985134021, 980192343, 501001227, 994478352, 952743843, 975840275, 950930734, 997688041, 997685273, 933083094, 956036953, 994124736, 987885761, 982498446, 979359694, 980802088, 982902873, 467905985, 972935946, 991820267, 995791748, 995482491, 983960299, 992486717, 979598625, 976571625, 983960340, 984672648, 981515283, 739215738, 978206178]
      # uber, snapchat, dash (mac app)
      ios_apps = app_identifiers.map do |app_identifier|
        IosApp.find_or_create_by!(app_identifier: app_identifier)
      end

      app_store = AppStore.find_or_create_by!(country_code: 'us')
      job = IosAppCurrentSnapshotJob.find_or_create_by!(id: 1)

      new.perform(job.id, ios_apps.map(&:id), app_store.id)
    end
  end
end
