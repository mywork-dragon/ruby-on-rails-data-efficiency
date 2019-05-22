# Used in ApiController

class IosLiveScanService
  class << self
    def scan_ios_app(ios_app_id:, job_type: :one_off, international_enabled: false)

      app = IosApp.find(ios_app_id)

      return nil if app.nil?

      job = IpaSnapshotJob.create!(
        job_type: job_type,
        live_scan_status: :validating,
        notes: "running a single live scan job on app #{ios_app_id} with type #{job_type}",
        international_enabled: international_enabled
      )

      IosLiveScanServiceWorker.perform_async(job.id, ios_app_id)
      RedshiftLogger.new(records: [{
        name: 'ios_scan_attempt',
        ios_scan_type: 'live',
        ios_app_id: app.id,
        ios_app_identifier: app.app_identifier
      }]).send!

      job.id
    end

    def check_status(job_id:)

      result_map = {
        validating: 0,
        unchanged: 1,
        not_available: 2,
        paid: 3,
        device_incompatible: 4,
        preparing: 5,
        devices_busy: 6,
        downloading: 7,
        retrying: 8,
        scanning: 9,
        complete: 10,
        failed: 11
      }

      job = IpaSnapshotJob.find(job_id)

      return nil if job.nil? || !(job.job_type == 'one_off' || job.job_type == 'test')

      snapshot = job.ipa_snapshots.first # shouldn't matter...only one snapshot

      # first set of checks: validation stage
      status = if %w(validating not_available paid unchanged device_incompatible failed).include?(job.live_scan_status)
        result_map[job.live_scan_status.to_sym]
      elsif job.live_scan_status != "initiated"
        result_map[:validating]
      end

      return status if !status.nil?

      # second set of checks: download and scan stages
      # Note: the order of these checks matter
      status = if snapshot.nil? || snapshot.download_status.nil?
        result_map[:preparing]
      elsif snapshot.scan_status == 'scanned'
        result_map[:complete]
      elsif snapshot.scan_status == 'scanning' || (snapshot.download_status == 'complete' && snapshot.success)
        result_map[:scanning]
      elsif snapshot.scan_status == 'failed'
        result_map[:failed]
      elsif snapshot.download_status == 'complete' && snapshot.success == false
        exception = snapshot.ipa_snapshot_exceptions.last
        exception && exception.error_code == 'devices_busy' ? result_map[:devices_busy] : result_map[:failed]
      elsif snapshot.download_status == 'starting' || snapshot.download_status == 'cleaning'
        result_map[:downloading]
      elsif snapshot.download_status == 'retrying'
        result_map[:retrying]
      else
        result_map[:failed]
      end

      status
    end

    def check_status_v2(job_id:)
      result_map = {
        validating: 0,
        unchanged: 1,
        not_available: 2,
        paid: 3,
        device_incompatible: 4,
        preparing: 5,
        devices_busy: 6,
        downloading: 7,
        retrying: 8,
        scanning: 9,
        complete: 10,
        failed: 11
      }

      job = IpaSnapshotJob.find(job_id)

      return nil if job.nil? || !(job.job_type == 'one_off' || job.job_type == 'test')

      # first set of checks: validation stage
      status = if %w(validating not_available paid unchanged device_incompatible failed).include?(job.live_scan_status)
        result_map[job.live_scan_status.to_sym]
      elsif job.live_scan_status != "initiated"
        result_map[:validating]
      end

      return status if !status.nil?

      # second set of checks: download and scan stages
      # Note: the order of these checks matter
      all_snapshots = job.ipa_snapshots
      not_failed_snapshots = all_snapshots.where(success: [true, nil])
      download_snapshot = not_failed_snapshots.order(:download_status).last || all_snapshots.order(:download_status).last
      scan_snapshot = not_failed_snapshots.order(:scan_status).last || all_snapshots.order(:scan_status).last

      status = if all_snapshots.empty? || (download_snapshot.download_status.nil?)
        result_map[:preparing]
      elsif scan_snapshot.scan_status == 'scanned'
        result_map[:complete]
      elsif scan_snapshot.scan_status == 'scanning' || (download_snapshot.download_status == 'complete' && download_snapshot.success != false)
        result_map[:scanning]
      elsif all_snapshots.all? { |x| x.scan_status == 'failed' || x.success == false }
        result_map[:failed]
      elsif download_snapshot.download_status == 'starting' || download_snapshot.download_status == 'cleaning'
        # check for any failed scans to prevent status from jumping from 'scanning' to 'downloading'
        if all_snapshots.any? { |x| x.scan_status == 'failed' }
          result_map[:scanning]
        else
          result_map[:downloading]
        end
      elsif download_snapshot.download_status == 'retrying'
        result_map[:retrying]
      else
        result_map[:failed]
      end

      status
    end
  end
end
