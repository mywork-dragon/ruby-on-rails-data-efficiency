################### NOT IN USE #####################
class IosParentService

  class << self

    def run(app_identifier)

      # get a device
      device = reserve_device
      return nil if device.blank?

      snapshot = IpaSnapshot.create!(ios_app_id: app_identifier)
      result = get_dump(app_identifier, device)

      # don't upload files in development mode
      file = if !Rails.env.development? && result[:outfile]
        File.open(result[:outfile])
      end

      data_keys = [
        :success,
        :duration,
        :install_time,
        :install_success,
        :dump_time,
        :dump_success,
        :teardown_success,
        :teardown_time,
        :error,
        :trace,
        :error_root,
        :error_teardown,
        :error_teardown_trace,
        :teardown_retry,
        :method
      ]

      row = result.select {|key| data_keys.include? key }
      row[:class_dump] = file
      row[:ipa_snapshot_id] = snapshot.id
      ClassDump.create!(row)

      release_device(device)

      result
    end

    def reserve_device(purpose, id = nil)

      purpose = :one_off if purpose.nil?

      device = IosDevice.transaction do

        d = if id.nil?
          IosDevice.lock.where(in_use: false, purpose: purpose).order(:last_used).first
        else
          IosDevice.lock.find_by_id(id)
        end
        d.in_use = true
        d.last_used = DateTime.now
        d.save
        d
      end

      device
    end

    def release_device(device)
      device.in_use = false
      device.save
    end

    def get_dump(app_identifier, device)
      IosDeviceService.new(device, device.ip, "root", "padme").run(app_identifier)
    end

    ########### Functions for local development only ###########
    def run_many(id = nil)

      device = get_device(id)

      # swift_apps = [
      #   628677149, # yahoo
      #   288429040, # linked in
      #   376812381, # getty images
      #   # 624329444, # argus - memory issues
      #   419950680, # hipmunk
      #   917418728, # slideshare (entirely Swift)
      # ]

      # other_apps = [
      #   364297166, # zinio
      #   529379082, # lyft
      # ]

      apps = [
        577232024, # Lumosity
        363590051, # Netflix
        307906541, # Fandango
        284235722, # Flixster
        376510438,
        530957474,
        364191819,
        342792525,
        918820076,
        429610587,
        545519333,
        377194688,
        342643402,
      ]



      puts "Trying apps"

      results = []
      apps.each do |app_identifier|
        puts "app #{results.length}: #{app_identifier}"
        results.push(single(app_identifier))
      end

      puts "Finished"
      results
    end

    # for testing without uploading results to database
    def single(app_identifier, id=nil)

      # get a device
      device = reserve_device(id)
      return nil if device.blank?

      res = get_dump(app_identifier, device)

      release_device(device)

      res

    end

  end



end

