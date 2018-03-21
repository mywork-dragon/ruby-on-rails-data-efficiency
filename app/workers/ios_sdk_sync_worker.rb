class IosSdkSyncWorker

  include Sidekiq::Worker

  sidekiq_options retry: 2, queue: :ios_reclassification

  def perform(uid, info)
    sdk = create_or_update_sdk(uid, info)
    adjust_header_info(sdk, info['classes']) if info['classes']
    adjust_framework_info(sdk, info['frameworks']) if info['frameworks']
    adjust_file_regex_info(sdk, info['file_regexes']) if info['file_regexes']
  end

  def create_or_update_sdk(uid, info)
    sdk = IosSdk.find_by_uid(uid)
    if sdk.nil?
      sdk = IosSdk.create_manual(
        name: info['name'],
        uid: uid,
        website: info['website'],
        kind: :native,
        summary: info['summary']
      )
    elsif sdk.flagged || sdk_info_changed?(sdk, info)
      sdk.update!(
        flagged: false,
        name: info['name'],
        website: info['website']
      )
    end
    sdk
  end

  def adjust_file_regex_info(sdk, file_regexes)
    regexes = file_regexes.map { |x| Regexp.new(x) }
    existing = sdk.sdk_file_regexes.pluck(:regex)
    to_remove = existing - regexes
    SdkFileRegex.where(regex: to_remove, ios_sdk_id: sdk.id).delete_all if to_remove.present?
    to_add = (regexes - existing).each { |r| SdkFileRegex.create!(regex: r, ios_sdk_id: sdk.id) }
  end

  def sdk_info_changed?(sdk, info)
    sdk.name != info['name'] ||
      sdk.website != info['website']
  end

  def adjust_header_info(sdk, headers)
    # no longer use cocoapods info
    sdk.cocoapod_source_datas.where(flagged: false).update_all(flagged: true)
    existing = sdk.ios_sdk_source_datas.pluck(:name)
    to_remove = existing - headers
    IosSdkSourceData.where(name: to_remove, ios_sdk_id: sdk.id).delete_all if to_remove.present?
    to_add = (headers - existing).map {|n| IosSdkSourceData.new(ios_sdk_id: sdk.id, name: n)}
    IosSdkSourceData.import(to_add) if to_add.present?
  end

  def adjust_framework_info(sdk, frameworks)
    existing = sdk.ios_classification_frameworks.pluck(:name)
    to_remove = existing - frameworks
    IosClassificationFramework.where(name: to_remove, ios_sdk_id: sdk.id).delete_all if to_remove.present?
    to_add = (frameworks - existing).map {|n| IosClassificationFramework.new(ios_sdk_id: sdk.id, name: n)}
    IosClassificationFramework.import(to_add) if to_add.present?
  end

end
