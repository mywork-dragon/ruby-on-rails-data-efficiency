class CocoapodServiceWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :scraper

	def perform(cocoapod_id)

    # scrape(char, res_count, offset)

    download_source(cocoapod_id)

  end

  def scrape(char, res_count, offset)

    ActiveRecord::Base.logger.level = 1

    cocoapods_url = "https://search.cocoapods.org/api/v1/pods.picky.hash.json"

    url = "#{cocoapods_url}?query=on%3Aios+#{char}&ids=#{res_count}&offset=#{offset}&sort=name"

    puts "Scraping #{char}, #{res_count} - #{res_count.to_int + offset.to_int}"
    
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

    cocoapod = Cocoapod.find_by_id(cocoapod_id)

    url = cocoapod.http

    source_code_url = if url.blank?

      url = cocoapod.git

      company = url[/.com+[^a-zA-Z](?!.*.com+[^a-zA-Z])(.*?)\//,1]

      repo = url[/#{company}\/(.*?)\./,1]

      'https://codeload.github.com/' + company + '/' + repo + '/zip/master'

    else

      url.gsub(/(?<=.zip).+/,'')

    end

    return nil if cocoapod.nil? || source_code_url.nil?

    ext = '.zip'

    basename = cocoapod.name

    dump = Rails.env.production? ? '"/mnt/sdk_dump/"' : '../sdk_dump/'

    filename = dump + basename + ext

    headers = {
      'Content-Type' => 'application/zip',
      'User-Agent' => UserAgent.random_web
    }

    uri = URI(source_code_url)

    data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers})

    File.open(filename, 'wb') { |f| f.write data.body }

    Dir.mkdir dump + basename

    Zip::ZipFile.open(filename) do |zip_file|

      zip_file.each do |entry|

        entry.extract( dump + basename + '/' + entry.name )

        if File.extname(entry.name) == '.h'

          parse_header(filename: dump + basename + '/' + entry.name, cocoapod_id: cocoapod_id)

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

      begin

        CocoapodSourceData.find_or_create_by(name: name[1], cocoapod_id: cocoapod_id)

      rescue

        nil

      end

    end

  end

end