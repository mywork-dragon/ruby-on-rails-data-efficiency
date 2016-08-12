class IosReclassificationServiceWorker < IosMassClassificationServiceWorker

  # only classify the below sources
  def classify_all_sources(ipa_snapshot_id:, classdump:, summary:)
    classdump_sdks = classify_classdump(summary['binary']['classdump'])
    # files_sdks = sdks_from_files(summary['files'])
    # strings_regex_sdks = sdks_from_string_regex(summary['binary']['strings'])
    # js_tag_sdks = sdks_from_js_tags(ipa_snapshot_id, summary['files'])
    # dll_sdks = sdks_from_dlls(ipa_snapshot_id, summary['files'])

    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: classdump_sdks, method: :classdump)
    # attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: files_sdks, method: :file_regex)
    # attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: js_tag_sdks, method: :js_tag_regex)
    # attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: dll_sdks, method: :dll_regex)
    # attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: strings_regex_sdks, method: :string_regex)
  end

  def attribute_sdks_to_snap(snap_id:, sdks:, method:)
    
    ios_sdk_ids = sdks.map(&:id)

    IosSdksIpaSnapshot.where(
      ipa_snapshot_id: snap_id,
      ios_sdk_id: ios_sdk_ids,
      method: nil
    ).delete_all

    existing = IosSdksIpaSnapshot.where(
      ipa_snapshot_id: snap_id,
      ios_sdk_id: ios_sdk_ids,
      method: IosSdksIpaSnapshot.methods[method]
    )

    remaining = ios_sdk_ids - existing.map(&:ios_sdk_id)

    rows = remaining.map do |ios_sdk_id|
      IosSdksIpaSnapshot.new(
        ipa_snapshot_id: snap_id,
        ios_sdk_id: ios_sdk_id,
        method: IosSdksIpaSnapshot.methods[method]
      )
    end

    IosSdksIpaSnapshot.import rows
  end

  def invalidate_bad_scans(snapshot)
    nil
  end

  def log_activities(snapshot)
    nil
  end
end
