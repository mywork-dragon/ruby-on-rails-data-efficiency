# Only used in AndroidSdkRelinkService
#
# class AndroidSdkRelinkWorker
#   include Sidekiq::Worker
#
#   sidekiq_options queue: :sdk
#
#   def perform(android_app_id)
#     android_app = AndroidApp.find(android_app_id)
#     apk_ss = android_app.apk_snapshots.where(status: 1, scan_status: 1).last
#     return if apk_ss.blank?
#
#     link_packages(apk_ss)
#     link_dlls(apk_ss)
#     link_js_tags(apk_ss)
#
#     true
#   end
#
#   def link_packages(apk_ss)
#     sdk_packages = apk_ss.sdk_packages
#
#     packages_s = sdk_packages.map do |sdk_package|
#       package = sdk_package.package
#       package.blank? ? nil : package
#     end.compact.join("\n")
#
#     SdkRegex.find_in_batches(batch_size: 1000) do |batch|
#       batch.each do |sdk_regex|
#         regex_s = sdk_regex.regex
#         next if regex_s.blank?
#         regex = Regexp.new(regex_s)
#
#         if regex.match(packages_s)
#           if AndroidSdksApkSnapshot.where(apk_snapshot_id: apk_ss.id, android_sdk_id: sdk_regex.android_sdk_id).empty?
#             begin
#               AndroidSdksApkSnapshot.create!(apk_snapshot_id: apk_ss.id, android_sdk_id: sdk_regex.android_sdk_id)
#             rescue ActiveRecord::RecordNotUnique => e
#               # do nothing
#             end
#           end
#         end
#       end
#     end
#   end
#
#   def link_dlls(apk_ss)
#     sdk_dlls = apk_ss.sdk_dlls
#
#     names_s = sdk_dlls.map do |sdk_dll|
#       name = sdk_dll.name
#       name.blank? ? nil : name
#     end.compact.join("\n")
#
#     DllRegex.find_in_batches(batch_size: 1000) do |batch|
#       batch.each do |dll_regex|
#         regex = dll_regex.regex
#         next if regex.blank?
#
#         if regex.match(names_s)
#           if AndroidSdksApkSnapshot.where(apk_snapshot_id: apk_ss.id, android_sdk_id: dll_regex.android_sdk_id).empty?
#             begin
#               AndroidSdksApkSnapshot.create!(apk_snapshot_id: apk_ss.id, android_sdk_id: dll_regex.android_sdk_id)
#             rescue ActiveRecord::RecordNotUnique => e
#               # do nothing
#             end
#           end
#         end
#       end
#     end
#   end
#
#   def link_js_tags(apk_ss)
#     sdk_js_tags = apk_ss.sdk_js_tags
#
#     names_s = sdk_js_tags.map do |sdk_js_tag|
#       name = sdk_js_tag.name
#       name.blank? ? nil : name
#     end.compact.join("\n")
#
#     JsTagRegex.find_in_batches(batch_size: 1000) do |batch|
#       batch.each do |js_tag_regex|
#         regex = js_tag_regex.regex
#         next if regex.blank?
#
#         if regex.match(names_s)
#           if AndroidSdksApkSnapshot.where(apk_snapshot_id: apk_ss.id, android_sdk_id: js_tag_regex.android_sdk_id).empty?
#             begin
#               AndroidSdksApkSnapshot.create!(apk_snapshot_id: apk_ss.id, android_sdk_id: js_tag_regex.android_sdk_id)
#             rescue ActiveRecord::RecordNotUnique => e
#               # do nothing
#             end
#           end
#         end
#       end
#     end
#   end
#
# end
