module Android
  module Scanning
    module RedshiftStatusLogger

      NAME_ATTEMPT = 'android_scan_attempt'.freeze

      def log_multiple_app_scan_status_to_redshift(android_apps, status, scan_type, extra_columns = {})
        send_logs(android_apps, status, scan_type, extra_columns)
      end


      def log_app_scan_status_to_redshift(android_app, status, scan_type, extra_columns = {})
        send_logs([android_app], status, scan_type, extra_columns)
      end

      # private

      def send_logs(android_apps, status, scan_type, extra_columns = {})
        redshift_logger = ::RedshiftLogger.new
        android_apps.each do |android_app|
          record = {
            name: name(status),
            android_scan_type: scan_type.to_s,
            android_app_id: android_app.id,
            android_app_identifier: android_app.app_identifier
          }
          record.merge!(extra_columns) if extra_columns.present?
          redshift_logger.add(record)
        end
        redshift_logger.send!
      rescue => e
        Bugsnag.notify(e)
      end

      def name(status)
        case status
        when :attempt
         NAME_ATTEMPT
        end
      end
    end
  end
end
