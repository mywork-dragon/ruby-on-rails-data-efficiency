class IosSdkSourceAnalysisWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  SIMILARITY_REQUIREMENT = 0.1

  def perform(ios_sdk_id)

    sdk = IosSdk.find(ios_sdk_id)

    pod_ids = sdk.cocoapods.map {|pod| pod.id}
    names = CocoapodSourceData.where(cocoapod_id: pod_ids).map {|source_row| source_row.name}.uniq

    conflicts = CocoapodSourceData.where(name: names).select {|row| !pod_ids.include?(row.cocoapod_id)}

    conflicts.group_by {|x| x.cocoapod_id}.each do |cocoapod_id, collisions|
      if collisions.length > names.length * SIMILARITY_REQUIREMENT
        match_sdk = Cocoapod.find(cocoapod_id).ios_sdk
        IosSdkSourceMatch.create!(source_sdk_id: ios_sdk_id, match_sdk_id: match_sdk.id, collisions: collisions.length, total: names.length, ratio: names.length == 0 ? 0 : (1.0 * collisions.length) / names.length)
      end
    end
  end
end