class CocoapodServiceWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :scraper

	def perform(cocoapod_id)

    # scrape(char, res_count, offset)

    download_source(cocoapod_id)

  end

  def scrape(char, res_count, offset)

    ActiveRecord::Base.logger.level = 1

    base = "https://search.cocoapods.org/api/v1/pods.picky.hash.json"

    url = "#{base}?query=on%3Aios+#{char}&ids=#{res_count}&offset=#{offset}&sort=name"

    puts "Scraping #{char}, #{offset} - #{res_count.to_int + offset.to_int}"
    
    begin

      cocoapods = JSON.parse(Proxy.get(req: url).body).to_h

    rescue => e

      CocoapodException.create(name: "#{url}\n\n#{e.message}")

      raise

    else

      results = cocoapods['allocations']

      5.times do |i|

        next if results[i].nil?
      
        res = results[i][5]

        next if res.nil?

        res.each do |r|

          begin

            s = r['source']
            git = s['git']
            http = s['http']
            tag = s['tag']
            summ = r['summary']
            link = r['link']
            cdocs = r['cocoadocs']
            name = r['id']
            ver = r['version']

            cp = Cocoapod.create(git: git, http: http, tag: tag, summary: summ, link: link, cocoadocs: cdocs, name: name, version: ver)

            r['authors'].each do |name, email|

              CocoapodAuthor.find_or_create_by(name: name, email: email, cocoapod: cp)
            
            end

            r['tags'].each do |tag|

              CocoapodTag.create(tag: tag, cocoapod: cp)

            end

          rescue

            nil

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

    basename = cocoapod.name

    dump = Rails.env.production? ? '/mnt/sdk_dump/' : '../sdk_dump/'

    filename = dump + basename + '.zip'

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

        # if File.extname(entry.name) == '.h'

        #   parse_header(filename: dump + basename + '/' + entry.name, cocoapod_id: cocoapod_id)

        # end

      end

    end

    unzipped_file = dump + basename

    podspec = `ls #{unzipped} | grep *.podspec`.chomp

    globs = podspec.scan(/(source_files |public_header_files )= (.?*)\n/).map{|k,v| v }

    globs = globs.map{|x| x.scan(/['"]{1}([^']+)['"]{1}/).flatten }.flatten

    files = globs.map{|glob| Dir.glob(unzipped_file+'/'+glob) }.flatten.uniq

    files.each do |file|
      parse_header(filename: file, cocoapod_id: cocoapod_id)
    end

    File.delete(filename)

    FileUtils.rm_rf(unzipped_file)

  end

  def parse_header(filename:, cocoapod_id:)

    return nil unless File.exist? filename

    file = File.open(filename).read

    names = file.scan(/(@interface|@protocol)\s(.*?)[^a-zA-Z]/i).uniq

    names.each do |name|

      next if in_apple_docs?(name[1]) || name[1].blank?

      begin

        CocoapodSourceData.find_or_create_by(name: name[1], cocoapod_id: cocoapod_id)

      rescue

        nil

      end

    end

  end

  def in_apple_docs?(q)

    apple_docs = AppleDoc.find_by_name(q)

    return true if apple_docs.present?

    uri = URI("https://developer.apple.com/search/search_data.php")

    headers = { 'User-Agent' => UserAgent.random_web }

    data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers}, params: {'q' => q})

    in_docs = JSON.parse(data.body).any?{ |res| res['description'].downcase.include? q.downcase }

    if in_docs

      AppleDoc.create(name: q)

      true

    else

      false

    end

  end

end