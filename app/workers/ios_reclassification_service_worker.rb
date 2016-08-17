class IosReclassificationServiceWorker < IosMassClassificationServiceWorker

  # only classify the below sources
  def classify_all_sources(ipa_snapshot_id:, classdump:, summary:)
    control = IosReclassificationControl.new

    classdump_sdks = classify_classdump(summary['binary']['classdump']) if control.is_active?(:classdump)
    frameworks_sdks = sdks_from_frameworks(summary['frameworks']) if control.is_active?(:frameworks)
    files_sdks = sdks_from_files(summary['files']) if control.is_active?(:file_regex)
    strings_regex_sdks = sdks_from_string_regex(summary['binary']['strings']) if control.is_active?(:string_regex)
    js_tag_sdks = sdks_from_js_tags(ipa_snapshot_id, summary['files']) if control.is_active?(:js_tag_regex)
    dll_sdks = sdks_from_dlls(ipa_snapshot_id, summary['files']) if control.is_active?(:dll_regex)

    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: classdump_sdks, method: :classdump) if classdump_sdks
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: frameworks_sdks, method: :frameworks) if frameworks_sdks
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: files_sdks, method: :file_regex) if files_sdks
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: strings_regex_sdks, method: :string_regex) if strings_regex_sdks
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: js_tag_sdks, method: :js_tag_regex) if js_tag_sdks
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: dll_sdks, method: :dll_regex) if dll_sdks
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
      method: IosSdksIpaSnapshot.methods[method] # index is not correct here
    )

    to_add = ios_sdk_ids - existing.map(&:ios_sdk_id)
    to_remove = existing.map(&:ios_sdk_id) - ios_sdk_ids

    IosSdksIpaSnapshot.where(
      ipa_snapshot_id: snap_id,
      ios_sdk_id: to_remove,
      method: IosSdksIpaSnapshot.methods[method]
    ).delete_all

    rows = to_add.map do |ios_sdk_id|
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
