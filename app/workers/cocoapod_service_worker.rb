class CocoapodServiceWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :scraper

	def perform(char, res_count, offset)

    scrape(char, res_count, offset)

  end

  def scrape(char, res_count, offset)

    cocoapods_url = "https://search.cocoapods.org/api/v1/pods.picky.hash.json"

    url = "#{cocoapods_url}?query=on%3Aios+#{char}&ids=#{res_count}&offset=#{offset}&sort=name"
    
    begin

      cocoapods = JSON.parse(Proxy.get(req: url).body).to_h

    rescue => e

      CocoapodException.create(name: "#{url}\n\n#{e.message}")

      raise

    else

      results = cocoapods['allocations']

      5.times do |i|

        if results[i].present?
        
          res = results[i][5]

          if res.present?

            res.each do |result|

              begin

                cp = Cocoapod.create(git: result['source']['git'], http: result['source']['http'], tag: result['source']['tag'], summary: result['summary'], link: result['link'], cocoadocs: result['cocoadocs'], name: result['id'], version: result['version'])

                result['authors'].each do |name, email|

                  CocoapodAuthor.find_or_create_by(name: name, email: email, cocoapod: cp)
                
                end

                result['tags'].each do |tag|

                  CocoapodTag.create(tag: tag, cocoapod: cp)

                end

              rescue

                nil

              end
              
            end

          end

        end

      end

    end


  end




  def download_source(cocoapod_id)

    # cocoapod_id = 1

    # srcs = %w(
    #   https://s3-eu-west-1.amazonaws.com/download.appsflyer.com/ios/AF-iOS-SDK-v3.3.1.zip
    #   https://kit-downloads.fabric.io/ios/com.twitter.crashlytics.ios/3.3.4/com.twitter.crashlytics.ios-default.zip
    # )

    cocoapod = Cocoapod.find_by_id(cocoapod_id)

    source_code_url = cocoapod.source_code_url

    return nil if cocoapod.nil?

    ext = File.extname(source_code_url)

    basename = File.basename(source_code_url, ext)

    dump = Rails.env.production? ? 'somedirectory' : '../sdk_dump/'

    filename = dump + basename + ext

    data = Proxy.get(req: source_code_url)

    File.open(filename, 'wb') { |f| f.write data.body }

    if ext == '.zip'

      Dir.mkdir dump + basename

      Zip::ZipFile.open(filename) do |zip_file|

        zip_file.each do |entry|

          entry.extract( dump + basename + '/' + entry.name )

          if File.extname(entry.name) == '.h'

            parse_header(filename: dump + basename + '/' + entry.name, cocoapod_id: cocoapod_id)

          end

        end

      end

    end

    File.delete(filename)

    FileUtils.rm_rf(dump+basename)

  end

  def parse_header(filename:, cocoapod_id:)

    file = File.open(filename).read

    names = file.scan(/(@interface|@protocol)\s(.*?)[^a-zA-Z]/i).uniq

    names.each do |name|

      CocoapodClasses.create(name: name[1], cocoapod_id: cocoapod_id)

    end

  end

end