class PackageSearchServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk_single

  def perform(app_id)

    aa = AndroidApp.find(app_id)

    app_identifier = aa.app_identifier

    nas = aa.newest_apk_snapshot

    return nil if nas.blank?

    apk_snapshot_id = nas.id

    find_packages(app_identifier: app_identifier, apk_snapshot_id: apk_snapshot_id)

  end


  def find_packages(app_identifier:, apk_snapshot_id:)

    if Rails.env.production?

      file_name = ApkSnapshot.find(apk_snapshot_id).apk_file.apk.url

      apk = Android::Apk.new(open(file_name))

    elsif Rails.env.development?
      
      file_name = '../../Documents/' + app_identifier + '.apk'

      apk = Android::Apk.new(file_name)
    
    end

    dex = apk.dex

    clss = dex.classes.map do |cls|

      next if cls.name.blank? || cls.name.downcase.include?(app_identifier.split('.')[1].downcase)

      cls = cls.name.split('/')

      cls.pop

      cls = cls.join('.')

      cls.slice!(0) if cls.slice(0) == 'L'

      cls

    end

    batch = Sidekiq::Batch.new

    batch.on(:complete, PackageSearchServiceWorker, 'apk_snapshot_id' => apk_snapshot_id)

    batch.jobs do

      clss.uniq.compact.uniq.each do |package_name|
        
        SavePackageServiceWorker.perform_async(package_name, apk_snapshot_id)

      end

      apk_snap = ApkSnapshot.find_by_id(apk_snapshot_id)

      apk_snap.scan_statuses[:scan_success]
      
      apk_snap.save

    end

  end

  def on_complete(status, options)

    apk_snap = ApkSnapshot.find_by_id(options['apk_snapshot_id'])
      
    apk_snap.scan_status = ApkSnapshot.scan_statuses[:scan_success]

    apk_snap.save

  end

  
end