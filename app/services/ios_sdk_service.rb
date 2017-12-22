class IosSdkService

  class << self

    def get_sdk_response(ios_app_id, force_live_scan_enabled=false)
      res = app_display_status(ios_app_id, force_live_scan_enabled)
      res.merge(IosApp.find(ios_app_id).sdk_history)
    end

    def get_tagged_sdk_response(ios_app_id, only_show_tagged=false, force_live_scan_enabled: false)
      res = app_display_status(ios_app_id, force_live_scan_enabled)
      res.merge(IosApp.find(ios_app_id).tagged_sdk_history(only_show_tagged))
    end

    def app_display_status(ios_app_id, force_live_scan_enabled)
      resp = {
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

      resp
    end

  end
end
