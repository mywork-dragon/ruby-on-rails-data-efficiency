class IosSdkService

  DEFAULT_FAVICON = 'https://assets-cdn.github.com/pinned-octocat.svg'

  class << self

    # for front end - getting sdks data into display type
    def get_sdk_response(ios_app_id)
      resp = {
        installed_sdk_companies: {},
        installed_open_source_sdks: {},
        uninstalled_sdk_companies: {},
        uninstalled_open_source_sdks: {},
        updated: nil,
        error_code: nil
      }

      def format_sdk(sdk)
        {
          'id' => sdk.id,
          'name' => sdk.name,
          'website' => sdk.website,
          'favicon' => sdk.favicon || DEFAULT_FAVICON
        }
      end

      # return error if it's not a free app
      app = IosApp.find(ios_app_id)

      price = Rails.env.production? ? app.newest_ios_app_snapshot.price.to_i : 0

      if !price.zero?
        resp[:error_code] = 0
        return resp
      end

      snap = app.get_last_ipa_snapshot(success: true)

      # if no successful scan's done, return no data
      if !snap.nil?
        snap.ios_sdks.each do |sdk|

          next if sdk.nil? || sdk.flagged

          if sdk.open_source
            resp[:installed_open_source_sdks][sdk.name] = format_sdk(sdk)
          else
            resp[:installed_sdk_companies][sdk.name] = format_sdk(sdk)
          end
        end

        resp[:updated] = snap.updated_at
      end

      resp
    end

  end
end