class IosSdkService

  DEFAULT_FAVICON = FaviconService.get_default_favicon

  class << self

    # for front end - getting sdks data into display type
    def get_sdk_response(ios_app_id)
      resp = {
        installed_sdks: [],
        uninstalled_sdks: [],
        updated: nil,
        error_code: nil,
        live_scan_enabled: nil
      }

      error_map = {
        paid: 0,
        taken_down: 1,
        foreign: 2,
        device_incompatible: 3,
        not_ios: 4
      }

      # pass flag through
      resp[:live_scan_enabled] = ServiceStatus.is_active?(:ios_live_scan) || Rails.application.config.env['stage'] != 'web'

      # return error if it violates some conditions
      app = IosApp.find(ios_app_id)

      if app.display_type != "normal"
        resp[:error_code] = error_map[app.display_type.to_sym]
      end

      price = Rails.env.production? ? app.newest_ios_app_snapshot.price.to_i : 0

      if !price.zero?
        resp[:error_code] = error_map[:paid]
      end

      snap = app.get_last_ipa_snapshot(scan_success: true)

      if !snap.nil?
        installed_sdks = snap.ios_sdks

        # handle the installed ones
        first_snaps_with_current_sdks = IpaSnapshot.joins(:ios_sdks_ipa_snapshots).select('min(first_valid_date) as first_seen', :version, :ios_app_id, 'ios_sdk_id').where(id: app.ipa_snapshots.scanned, 'ios_sdks_ipa_snapshots.ios_sdk_id' => installed_sdks.pluck(:id)).group('ios_sdk_id')

        # handle the uninstalled ones
        last_snaps_without_current_sdks = IpaSnapshot.joins(:ios_sdks_ipa_snapshots).select('max(good_as_of_date) as last_seen', 'version', 'ios_sdk_id').where(id: app.ipa_snapshots.scanned).where.not('ios_sdks_ipa_snapshots.ios_sdk_id' => installed_sdks.pluck(:id)).group('ios_sdk_id')

        uninstalled_sdks = IosSdk.where(id: last_snaps_without_current_sdks.pluck(:ios_sdk_id))

        installed_display_sdk_to_snap = IosSdk.joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').select('ios_sdks.id as k, IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id) as v').where(id: installed_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']

          current_snapshot = first_snaps_with_current_sdks.find { |snapshot| snapshot.ios_sdk_id == map_row['k'] }

          if memo[key].nil? || current_snapshot.first_seen < memo[key].first_seen
            memo[key] = current_snapshot
          end

          memo
        end

        # need to only show the "display sdks", ones that are linked. Build a mapping and load the SDKs into memory
        uninstalled_display_sdk_to_snap = IosSdk.joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').select('ios_sdks.id as k, IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id) as v').where(id: uninstalled_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']
          current_snapshot = last_snaps_without_current_sdks.find {|snapshot| snapshot.ios_sdk_id == map_row['k']}

          if memo[key].nil? || current_snapshot.last_seen > memo[key].last_seen
            memo[key] = current_snapshot
          end

          memo
        end

        installed_display_sdks = IosSdk.where(id: IosSdk.select('IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id)').joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').where(id: installed_sdks))
        uninstalled_display_sdks = IosSdk.where(id: IosSdk.select('IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id)').joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').where(id: uninstalled_sdks))

        partioned_installed_sdks = partition_sdks(ios_sdks: installed_display_sdks)
        partioned_uninstalled_sdks = partition_sdks(ios_sdks: uninstalled_display_sdks)

        # format the responses
        resp[:installed_sdks] = partioned_installed_sdks.map do |sdk|
          formatted = format_sdk(sdk)
          ipa_snap = installed_display_sdk_to_snap[sdk.id]
          formatted['first_seen_date'] = ipa_snap ? ipa_snap.first_seen : nil
          formatted
        end.uniq

        resp[:uninstalled_sdks] = partioned_uninstalled_sdks.map do |sdk|
          next unless installed_display_sdk_to_snap[sdk.id].nil?
          formatted = format_sdk(sdk)
          ipa_snap = uninstalled_display_sdk_to_snap[sdk.id]
          formatted['last_seen_date'] = ipa_snap ? ipa_snap.last_seen : nil
          formatted
        end.compact.uniq

        resp[:updated] = snap.good_as_of_date
      end

      resp
    end

    def partition_sdks(ios_sdks:)
      partitions = ios_sdks.reduce({os: [], non_os: []}) do |memo, sdk|
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

    def format_sdk(sdk)
      {
        'id' => sdk.id,
        'name' => sdk.name,
        'website' => sdk.website,
        'favicon' => sdk.favicon || DEFAULT_FAVICON
      }
    end

  end
end
