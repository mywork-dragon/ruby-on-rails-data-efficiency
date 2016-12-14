module AndroidSdkService

  class App

    class << self

      def get_sdk_response(android_app_id, force_live_scan_enabled=false, apk_snapshot_id: nil)
        aa = AndroidApp.find(android_app_id)
        data = sdk_response_h(aa, force_live_scan_enabled, apk_snapshot_id: apk_snapshot_id)
      end

      # Maps the display type to the error code
      def display_type_to_error_code(display_type)
        display_type = display_type.try(:to_sym)
        mapping = {
          taken_down: 0, 
          foreign: 1,
          paid: 2
        }
        mapping[display_type] if display_type
      end

      # Helper for get_sdk_response
      def sdk_response_h(aa, force_live_scan_enabled=false, apk_snapshot_id: nil)
        h = {}
        ec = display_type_to_error_code(aa.display_type)

        snap = apk_snapshot_id.nil? ? aa.newest_successful_apk_snapshot : ApkSnapshot.find(apk_snapshot_id)

        h[:live_scan_enabled] = force_live_scan_enabled || ServiceStatus.is_active?(:android_live_scan)
        h[:error_code] = ec

        return h if snap.nil?

        installed_sdks = snap.android_sdks

        first_snaps_with_current_sdks = ApkSnapshot.joins(:android_sdks_apk_snapshots).select('max(good_as_of_date) as last_seen', 'min(first_valid_date) as first_seen', :version, :android_app_id, 'android_sdk_id').where(id: aa.apk_snapshots.scan_success, 'android_sdks_apk_snapshots.android_sdk_id' => installed_sdks.pluck(:id)).group('android_sdk_id')
        last_snaps_without_current_sdks = ApkSnapshot.joins(:android_sdks_apk_snapshots).select('max(good_as_of_date) as last_seen', 'min(first_valid_date) as first_seen', 'version', 'android_sdk_id').where(id: aa.apk_snapshots.scan_success).where.not('android_sdks_apk_snapshots.android_sdk_id' => installed_sdks.pluck(:id)).group('android_sdk_id')

        uninstalled_sdks = AndroidSdk.where(id: last_snaps_without_current_sdks.pluck(:android_sdk_id))

        installed_display_sdk_to_snap = AndroidSdk.joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').select('android_sdks.id as k, IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id) as v').where(id: installed_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']

          current_snapshot = first_snaps_with_current_sdks.find { |snapshot| snapshot.android_sdk_id == map_row['k'] }

          if memo[key].nil?
            memo[key] = {
              first_seen: current_snapshot.first_seen,
              last_seen: current_snapshot.last_seen
            }
          else
            memo[key] = {
              first_seen: [memo[key][:first_seen], current_snapshot.first_seen].min,
              last_seen: [memo[key][:last_seen], current_snapshot.last_seen].max
            }
          end

          memo
        end

        #puts "installed_display_sdk_to_snap: #{installed_display_sdk_to_snap}"  #debug

        uninstalled_display_sdk_to_snap = AndroidSdk.joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').select('android_sdks.id as k, IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id) as v').where(id: uninstalled_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']
          current_snapshot = last_snaps_without_current_sdks.find {|snapshot| snapshot.android_sdk_id == map_row['k']}

          if memo[key].nil?
            memo[key] = {
              first_seen: current_snapshot.first_seen,
              last_seen: current_snapshot.last_seen
            }
          else
            memo[key] = {
              first_seen: [memo[key][:first_seen], current_snapshot.first_seen].min,
              last_seen: [memo[key][:last_seen], current_snapshot.last_seen].max
            }
          end

          memo
        end

        installed_display_sdks = AndroidSdk.where(id: AndroidSdk.select('IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id)').joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').where(id: installed_sdks))
        uninstalled_display_sdks = AndroidSdk.where(id: AndroidSdk.select('IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id)').joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').where(id: uninstalled_sdks))

        partioned_installed_sdks = partition_sdks(android_sdks: installed_display_sdks)
        partioned_uninstalled_sdks = partition_sdks(android_sdks: uninstalled_display_sdks)

        # format the responses
        h[:installed] = partioned_installed_sdks.map do |sdk|
          formatted = format_sdk(sdk)
          apk_snap_metrics = installed_display_sdk_to_snap[sdk.id]
          formatted['last_seen_date'] = apk_snap_metrics ? apk_snap_metrics[:last_seen] : nil
          formatted['first_seen_date'] = apk_snap_metrics ? apk_snap_metrics[:first_seen] : nil
          formatted
        end.uniq

        h[:uninstalled] = partioned_uninstalled_sdks.map do |sdk|
          next unless installed_display_sdk_to_snap[sdk.id].nil?
          formatted = format_sdk(sdk)
          apk_snap_metrics = uninstalled_display_sdk_to_snap[sdk.id]
          formatted['last_seen_date'] = apk_snap_metrics ? apk_snap_metrics[:last_seen] : nil
          formatted['first_seen_date'] = apk_snap_metrics ? apk_snap_metrics[:first_seen] : nil
          formatted
        end.compact.uniq
        # h[:uninstalled] = {}  # show no uninstalls for now  -- TEMP
        h[:updated] = snap.good_as_of_date
        h[:error_code] = ec || nil
        h
      end

      def partition_sdks(android_sdks:)
        partitions = android_sdks.reduce({os: [], non_os: []}) do |memo, sdk|
          if sdk.present? && (!sdk.flagged || sdk.flagged == 0) 
            if FaviconHelper.has_os_favicon?(sdk.favicon) && !memo[:os].include?(sdk)
              memo[:os].push(sdk)
            elsif !memo[:non_os].include?(sdk)
              memo[:non_os].push(sdk)
            end
          end

          memo
        end

        %i(os non_os).each do |property|
          # use sort_by because it's an expensive operation and it's more efficient than sort for this type
          partitions[property] = partitions[property].sort_by do |sdk|
            sdk.name.downcase
          end
        end

        (partitions[:non_os] + partitions[:os]).uniq
      end

      def format_sdk(android_sdk)
        {
          'id' => android_sdk.id,
          'name' => android_sdk.name,
          'website' => android_sdk.website,
          'favicon' => android_sdk.get_favicon,
          'open_source' => android_sdk.open_source
        }
      end

    end

  end

end
