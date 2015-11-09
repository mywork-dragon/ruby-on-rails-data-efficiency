class CocoapodService

  class << self

    def get_everything

      res_count = 100

      (0...36).map{ |i| i.to_s 36}.each do |char|

        total_res_count = CocoapodService.char_result_count(char)

        page_count = (total_res_count / res_count.to_f).ceil

        page_count.times do |i|

          offset = res_count * i

          CocoapodServiceWorker.new.perform(char, res_count, offset)
          
        end

      end

    end

    def char_result_count(char)

      cocoapods_url = "https://search.cocoapods.org/api/v1/pods.picky.hash.json"

      url = "#{cocoapods_url}?query=on%3Aios+#{char}&ids=0&offset=0&sort=name"

      results = JSON.parse(Proxy.get(req: url).body).to_h

      results['total']

    end

    def inspect_source(start = 0)

      Cocoapod.where("id >= ?", start) do |pod|

        CocoapodServiceWorker.new.perform(pod.id) if pod.id >= start

      end

    end

    def inspect_source_n(n = 100)

      Cocoapod.limit(n).each do |pod|

        CocoapodServiceWorker.new.perform(pod.id)

      end

    end

    # [8155,85,14088,14087]

    def inspect_source_by_ids(ids = [14])

      ids.each do |id|

        CocoapodServiceWorker.new.perform(id)

      end

    end

    def dump
      classes_to_dump = [IosSdk, Cocoapod, CocoapodSourceData]

      classes_to_dump.each do |the_class|
        SeedDump.dump(the_class, file: "#{Rails.root.to_s}/db/#{the_class.to_s.underscore}.rb")
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

  end

end