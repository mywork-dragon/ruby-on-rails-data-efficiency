class IosSdkService

  DEFAULT_FAVICON = FaviconService.get_default_favicon

  class << self

    # for front end - getting sdks data into display type
    def get_sdk_response(ios_app_id, force_live_scan_enabled=false)
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
      resp[:live_scan_enabled] = force_live_scan_enabled || ServiceStatus.is_active?(:ios_live_scan)

      # return error if it violates some conditions
      app = IosApp.find(ios_app_id)

      if app.display_type != "normal" && app.display_type != 'taken_down'
        resp[:error_code] = error_map[app.display_type.to_sym]
      end

      resp[:error_code] = error_map[:taken_down] if !app.app_store_available

      price = Rails.env.production? ? app.newest_ios_app_snapshot.try(:price).to_i : 0

      if !price.zero?
        resp[:error_code] = error_map[:paid]
      end

      snap = app.get_last_ipa_snapshot(scan_success: true)

      if !snap.nil?
        installed_sdks = snap.ios_sdks

        # handle the installed ones
        first_snaps_with_current_sdks = IpaSnapshot.joins(:ios_sdks_ipa_snapshots).select('max(good_as_of_date) as last_seen', 'min(first_valid_date) as first_seen', :version, :ios_app_id, 'ios_sdk_id').where(id: app.ipa_snapshots.scanned, 'ios_sdks_ipa_snapshots.ios_sdk_id' => installed_sdks.pluck(:id)).group('ios_sdk_id')

        # handle the uninstalled ones
        last_snaps_without_current_sdks = IpaSnapshot.joins(:ios_sdks_ipa_snapshots).select('max(good_as_of_date) as last_seen', 'min(first_valid_date) as first_seen', 'version', 'ios_sdk_id').where(id: app.ipa_snapshots.scanned).where.not('ios_sdks_ipa_snapshots.ios_sdk_id' => installed_sdks.pluck(:id)).group('ios_sdk_id')

        uninstalled_sdks = IosSdk.where(id: last_snaps_without_current_sdks.pluck(:ios_sdk_id))

        installed_display_sdk_to_snap = IosSdk.joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').select('ios_sdks.id as k, IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id) as v').where(id: installed_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']

          current_snapshot = first_snaps_with_current_sdks.find { |snapshot| snapshot.ios_sdk_id == map_row['k'] }


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

        # need to only show the "display sdks", ones that are linked. Build a mapping and load the SDKs into memory
        uninstalled_display_sdk_to_snap = IosSdk.joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').select('ios_sdks.id as k, IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id) as v').where(id: uninstalled_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']
          current_snapshot = last_snaps_without_current_sdks.find {|snapshot| snapshot.ios_sdk_id == map_row['k']}
          first_snap_without_sdk = IpaSnapshot.joins(:ios_sdks_ipa_snapshots).where('good_as_of_date > ?', current_snapshot.last_seen).select('min(first_valid_date) as first_unseen').where(id: app.ipa_snapshots.scanned).where.not('ios_sdks_ipa_snapshots.ios_sdk_id' => memo['k']).first

          if memo[key].nil?
            memo[key] = {
              first_seen: current_snapshot.first_seen,
              last_seen: current_snapshot.last_seen,
              first_unseen: first_snap_without_sdk.first_unseen
            }
          else
            memo[key] = {
              first_seen: [memo[key][:first_seen], current_snapshot.first_seen].min,
              last_seen: [memo[key][:last_seen], current_snapshot.last_seen].max,
              first_unseen: [memo[key][:first_unseen], first_snap_without_sdk.first_unseen].min
            }
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
          ipa_snap_metrics = installed_display_sdk_to_snap[sdk.id]
          formatted['last_seen_date'] = ipa_snap_metrics ? ipa_snap_metrics[:last_seen] : nil
          formatted['first_seen_date'] = ipa_snap_metrics ? ipa_snap_metrics[:first_seen] : nil
          formatted
        end.uniq

        resp[:uninstalled_sdks] = partioned_uninstalled_sdks.map do |sdk|
          next unless installed_display_sdk_to_snap[sdk.id].nil?
          formatted = format_sdk(sdk)
          ipa_snap_metrics = uninstalled_display_sdk_to_snap[sdk.id]
          formatted['last_seen_date'] = ipa_snap_metrics ? ipa_snap_metrics[:last_seen] : nil
          formatted['first_seen_date'] = ipa_snap_metrics ? ipa_snap_metrics[:first_seen] : nil
          formatted['first_unseen_date'] = ipa_snap_metrics ? ipa_snap_metrics[:first_unseen] : nil
          formatted
        end.compact.uniq

        resp[:updated] = snap.good_as_of_date
      end

      resp
    end

    def get_tagged_sdk_response(ios_app_id, only_show_tagged=false, force_live_scan_enabled: false)
      new_sdk_response = { installed_sdks: Hash.new {[]}, uninstalled_sdks: Hash.new {[]},
                           installed_sdks_count: 0, uninstalled_sdks_count: 0 }
      untagged_name = 'Others'

      [:installed_sdks, :uninstalled_sdks].each do |type|
        sdks = get_sdk_response(ios_app_id)[type]
        sdks.each do |sdk|
          ios_sdk = IosSdk.find(sdk["id"])
          tag_name = ios_sdk.tags.first.try(:name) || untagged_name
          next if tag_name == untagged_name && only_show_tagged
          new_sdk_response[type][tag_name] += [sdk]
        end
      end

      installed_sdks, uninstalled_sdks = [], []
      ((new_sdk_response[:installed_sdks].keys - [untagged_name]).sort + [untagged_name]).each do |key|
        # don't add data for untagged_name unless we have sdks for it
        value = new_sdk_response[:installed_sdks][key]
        if value.present?
          installed_sdks << {name: key, sdks: value}
          new_sdk_response[:installed_sdks_count] += value.count
        end
      end

      ((new_sdk_response[:uninstalled_sdks].keys - [untagged_name]).sort + [untagged_name]).each do |key|
        # don't add data for untagged_name unless we have sdks for it
        value = new_sdk_response[:uninstalled_sdks][key]
        if value.present?
          uninstalled_sdks << {name: key, sdks: value}
          new_sdk_response[:uninstalled_sdks_count] += value.count
        end
      end

      new_sdk_response[:installed_sdks] = installed_sdks
      new_sdk_response[:uninstalled_sdks] = uninstalled_sdks

      get_sdk_response(ios_app_id).merge(new_sdk_response)
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
