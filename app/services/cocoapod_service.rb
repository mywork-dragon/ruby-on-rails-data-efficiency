class CocoapodService

  # cocoapod related utilities
  class << self

    def dump(classes_to_dump = nil)
      classes_to_dump = [IosSdk, Cocoapod, CocoapodSourceData] if classes_to_dump.nil?

      classes_to_dump.each do |the_class|
        SeedDump.dump(the_class, file: "#{Rails.root.to_s}/db/#{the_class.to_s.underscore}.rb", exclude: [:created_at, :updated_at])
      end
    end

    def seed
      directory = "#{Rails.root_to_s}/db/cocoapods"
      filenames = []

      filenames.each do |filename|
        require "./#{directory}/#{filename}"
      end
    end

    def load_accts(arr)
      def create_account(username, app, id, secret)
        GithubAccount.create!({username: username, email: "#{username}@gmail.com", password: "iamhairy1", application_name: app, homepage_url: "http://www.tobedetermined.com", callback_url: "http://www.tobedetermined.com", client_id: id, client_secret: secret})
      end

      arr.each do |acct|
        fields = acct.split(",").map {|x| x.lstrip.rstrip}
        create_account(fields.first.gsub("@gmail.com", ""), fields[1], fields[2], fields[3])
      end
    end

    # checks source data to see if there's a unique name
    def get_unique_classes(sdk_name)
      pod_ids = IosSdk.find_by_name(sdk_name).cocoapods.map {|pod| pod.id}
      CocoapodSourceData.where(cocoapod_id: pod_ids).select do |source_row|
        copies = CocoapodSourceData.where(name: source_row.name)
        copies.select {|row| row.id != source_row.id}.length == 0
      end.map {|row| row.name}
    end

    def apple_docs

      CocoapodSourceData.all.each do |d|

        CocoapodServiceWorker.new.in_apple_docs?(d.name)

      end

    end

    def retry_broken(ids = nil)

      ids = CocoapodException.select('cocoapod_id').map {|x| x.cocoapod_id} if ids.nil?

      ids.uniq.each do |id|
        if Rails.env.production?
          CocoapodDownloadWorker.perform_async(id)
        else
          CocoapodDownloadWorker.new.perform(id)
        end
      end
    end

    def find_sdk_similarities(sdk_names = nil, req = 0.2)


      sdks = sdk_names.nil? ? IosSdk.all.sample(10) : IosSdk.where(name: sdk_names)

      similar = {}

      sdks.each do |sdk|

        
        ids = sdk.cocoapods.map {|pod| pod.id}
        names = CocoapodSourceData.where(cocoapod_id: ids).map {|source_row| source_row.name}.uniq

        conflicts = CocoapodSourceData.where(name: names).select {|row| !ids.include?(row.cocoapod_id)}

        conflicts.group_by {|x| x.cocoapod_id}.each do |cocoapod_id, collisions|
          if collisions.length > names.length * req
            match = Cocoapod.find(cocoapod_id).ios_sdk.name
            similar[sdk.name] = similar[sdk.name].nil? ? [match] : similar[sdk.name] + [match]
          end
        end

      end

      ap similar
      similar

    end

    def retry_no_data(cocoapod_ids: nil)
      if cocoapod_ids.nil?
        w_data = CocoapodSourceData.select(:cocoapod_id).map {|csd| csd.cocoapod_id}.uniq
        all_cocoapods = Cocoapod.select(:id).map {|x| x.id}

        no_data = all_cocoapods - w_data

        ap "Found #{no_data.length.to_s} cocoapods without data"


      end

      if Rails.env.production?
        batch = Sidekiq::Batch.new
        batch.description = "retrying cocoapods without data"
        batch.on(:complete, 'CocoapodService#retry_no_data_on_complete')

        batch.jobs do
          no_data.each do |cocoapod_id|
            CocoapodDownloadWorker.perform_async(cocoapod_id)
          end
        end
      else
        CocoapodDownloadWorker.new.perform(no_data.sample)
      end


    end

  end

  def retry_no_data_on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'retrying no data cocoapods')
  end

end