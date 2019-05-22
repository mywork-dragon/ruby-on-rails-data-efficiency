# Used in ApiController

module AndroidSdkService

  class << self

    def get_tagged_sdk_response(android_app_id, only_show_tagged=false, force_live_scan_enabled: false)
      res = app_display_status(android_app_id, force_live_scan_enabled)
      res.merge(AndroidApp.find(android_app_id).tagged_sdk_history(only_show_tagged))
    end

    # Below methods should be private. They're just called from get_tagged_sdk_response

    def app_display_status(android_app_id, force_live_scan_enabled)
      resp = {
        error_code: nil,
        live_scan_enabled: nil
      }

      app = AndroidApp.find(android_app_id)

      resp[:error_code] = display_type_to_error_code(app.display_type)
      resp[:live_scan_enabled] = force_live_scan_enabled || ServiceStatus.is_active?(:android_live_scan)

      resp
    end

    # Maps the display type to the error code
    def display_type_to_error_code(display_type)
      display_type = display_type.try(:to_sym)
      mapping = {
        taken_down: 0,
        paid: 2
      }
      mapping[display_type] if display_type
    end

    # Not called anywhere
    # def get_sdk_response(android_app_id, force_live_scan_enabled=false)
    #   res = app_display_status(android_app_id, force_live_scan_enabled)
    #   res.merge(AndroidApp.find(android_app_id).sdk_history)
    # end

  end

end
