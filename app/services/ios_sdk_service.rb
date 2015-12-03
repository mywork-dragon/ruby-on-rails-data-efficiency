class IosSdkService

  DEFAULT_FAVICON = FaviconService.get_default_favicon

  class << self

    # for front end - getting sdks data into display type
    def get_sdk_response(ios_app_id)
      resp = {
        installed_sdks: [],
        updated: nil,
        error_code: nil
      }

      error_map = {
        price: 0,
        taken_down: 1,
        foreign: 2,
        device_incompatible: 3
      }

      # return error if it violates some conditions
      app = IosApp.find(ios_app_id)

      if app.display_type != "normal"
        resp[:error_code] = error_map[app.display_type.to_sym]
        return resp
      end

      price = Rails.env.production? ? app.newest_ios_app_snapshot.price.to_i : 0

      if !price.zero?
        resp[:error_code] = error_map[:price]
        return resp
      end

      snap = app.get_last_ipa_snapshot(scan_success: true)

      # if no successful scan's done, return no data
      if !snap.nil?

        partitions = snap.ios_sdks.reduce({os: [], non_os: []}) do |memo, sdk|
          if sdk.present? && !sdk.flagged
            if has_os_favicon?(sdk.favicon)
              memo[:os].push(sdk)
            else
              memo[:non_os].push(sdk)
            end
          end

          memo
        end

        %i(os non_os).each do |property|
          # use sort_by because it's an expensive operation and it's more efficient than sort for this type
          partitions[property] = partitions[property].sort_by do |sdk|
            sdk.get_current_apps(count_only: true)
          end
        end

        resp[:installed_sdks] = partitions[:non_os] + partitions[:os]

        resp[:updated] = snap.updated_at
      end

      resp
    end

    def format_sdk(sdk)
      {
        'id' => sdk.id,
        'name' => sdk.name,
        'website' => sdk.website,
        'favicon' => sdk.favicon || DEFAULT_FAVICON
      }
    end

    def has_os_favicon?(favicon_url)

      return nil if favicon_url.nil?

      known_os_favicons = %w(
        github
        bitbucket
        sourceforge
        alamofire
        afnetworking
      )
      favicon_url.match(/#{known_os_favicons.join('|')}/) ? true : false
    end

  end
end