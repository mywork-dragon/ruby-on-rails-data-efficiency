class EpfService

  EPF_USERNAME = 'epfuser99894'
  EPF_PASSWORD = '42413e32cb2759c0e96c9b3cb154c8e2'

  NUMBER_OF_FILES = 50 # Should be less than or equal to the number of threads
  
  FS = 1.chr
  RS = 2.chr + "\n"
  
  if Rails.env.production?
    EPF_DIRECTORY = '/mnt/epf'
  else
    EPF_DIRECTORY = '/Users/jason/penpals/epf/epf_service'
  end
  

  class << self
    
    
    def run_itunes_current
      urls = epf_snapshot_urls
      
      run_feed(file_url: urls[:current][:itunes_tbz], feed_symbol: :itunes, name: urls[:current][:name])
    end
    
    def files_for_feed(feed_symbol)
      case feed_symbol
      when :itunes
        %w(application)
      when :match
        raise '"match" not implemented'
      when :popularity
        raise '"popularity" not implemented'
      when :pricing
        raise '"pricing not implemented"'
      end
    end
    
    def send_slack_notifier(title)
      notifier = Slack::Notifier.new('https://hooks.slack.com/services/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')
      attachment = { fallback: title, title: title, color: '#00ff66'}
      notifier.ping('', attachments: [attachment])
    end
    
    # Valid feed symbols: :itunes, :match, :popularity, :pricing
    def run_feed(file_url:, feed_symbol:, name:)
         
      saved_file_path = EPF_DIRECTORY + '/' + file_url.split('/').last
      download(file_url, saved_file_path)  #download works

      puts 'EPF download complete'
      send_slack_notifier('EPF download complete')
      
      tbz_name = "#{feed_symbol.to_s}#{name}.tbz"
      saved_file_path = "#{EPF_DIRECTORY}/#{tbz_name}"
      
      puts "saved_file_path: #{saved_file_path}"
      
      unzip(saved_file_path)
      puts '.tbz unzipped'
      send_slack_notifier('.tbz unzipped.')
      
      files_for_feed(feed_symbol).each do |file|
        file_path = "#{EPF_DIRECTORY}/#{tbz_name.gsub('.tbz', '')}"
        puts file_path
        split("#{file_path}/#{file}")
      
        fix_partials(file.to_s)
      end      
      
      puts 'Partial files fixed.'
      send_slack_notifier('Partial files fixed.')
      
      store(feed_symbol: feed_symbol, name: name)
    end
    
    def store(feed_symbol:, name:)
      files_for_feed(feed_symbol).each do |main_file_name|
        
        epf_full_feed = EpfFullFeed.find_or_create_by(name: name)
        
        batch = Sidekiq::Batch.new
        batch.description = "EpfService, #{feed_symbol.to_s}, #{main_file_name}," 
        batch.on(:complete, self)
      
        batch.jobs do
          NUMBER_OF_FILES.times do |n|
            file = file_for_n(n: n, filename: main_file_name) 
            EpfServiceDbWorker.perform_async(epf_full_feed.id, main_file_name, file)
          end
        end
      end
    end
    
    # Oldest is first
    # current: The current snapshots
    # all: All snapshots
    def epf_snapshot_urls
      prefix = 'https://feeds.itunes.apple.com/feeds/epf/v3/full/'
      html = HTTParty.get(prefix, basic_auth: {username: EPF_USERNAME, password: EPF_PASSWORD}).response.body
      page = Nokogiri::HTML(html)
      
      
      all_names = page.css('a').map{ |x| x['href'] }.compact.select{ |x| x.match(/\d+\//)}.map{ |x| x.gsub('/', '') } 
      all = all_names.map do |name| 
        {
          name: name,
          itunes_tbz: "#{prefix}#{name}/itunes#{name}.tbz",
          match_tbz: "#{prefix}#{name}/match#{name}.tbz", 
          popularity_tbz: "#{prefix}#{name}/popularity#{name}.tbz", 
          pricing_tbz: "#{prefix}#{name}/pricing#{name}.tbz"
        } 
      end
      
      current = all.last
      
      {current: current, all: all}
    end
    
    # Download the latest version of the EPF
    def download(file_url, saved_file_path)
      `curl --user #{EPF_USERNAME}:#{EPF_PASSWORD} #{file_url} > #{saved_file_path}`
    end
    
    def unzip(file)
      `(cd #{EPF_DIRECTORY}; tar -xvf #{file})`
    end
    
    def split(file)
      filename = file.split('/').last
      split_cmd = (Rails.env.production? ? 'split' : 'gsplit')
      `(cd #{EPF_DIRECTORY}; #{split_cmd} -n #{NUMBER_OF_FILES} -a #{number_of_digits} -d #{file} #{filename}_)`
    end
    
    def fix_partials(main_file_name)
      
      (NUMBER_OF_FILES - 1).times do |n|        #don't do the last file
        split_file = file_for_n(n: n, filename: main_file_name)
        
        if n == 0 #remove stuff on first file
          file_s = File.open(split_file, "rb:UTF-8").read.scrub
          file_s_without_headers_and_legal = file_s.split('##legal: ' + RS).last
          File.open(split_file, 'w') { |file| file.write(file_s_without_headers_and_legal.encode('UTF-8', {invalid: :replace, undef: :replace, replace: ''})) }
        end
      
        next_split_file = file_for_n(n: n + 1, filename: main_file_name)
      
        partial_data = get_partial_data_from_end(split_file)
      
        add_partial_data_to_beginning(partial_data, next_split_file)
      
      end
    end
    
    # Gets it and removes it
    def get_partial_data_from_end(file)
      max_lines = 5e3
      
      file_s = File.open(file, "rb:UTF-8").read.scrub
      
      file_s_split = file_s.split(RS)
      
      file_s_trimmed = file_s_split[0..(file_s_split.size - 2)].join(RS) + RS #remove the last element
      
      File.open(file, 'w') { |file| file.write(file_s_trimmed.encode('UTF-8', {invalid: :replace, undef: :replace, replace: ''})) }
      
      file_s_split.last
    end
    
    def add_partial_data_to_beginning(partial_data, file)
      original_file = file
      new_file = original_file + '.new'
      
      File.open(new_file, 'w:UTF-8') do |fo|
        
        fo.print partial_data.to_s.encode('UTF-8', {invalid: :replace, undef: :replace, replace: ''})
        File.foreach(original_file) do |li|
          fo.puts li
        end
      end
      
      File.rename(original_file, original_file + '.old')
      File.rename(new_file, original_file)
      File.delete(original_file + '.old')
    end
    
    private
    
    def number_of_digits
      NUMBER_OF_FILES.to_s.length
    end
    
    def file_for_n(n:, filename:)
      suffix = n.to_s.rjust(number_of_digits, '0')
      EPF_DIRECTORY + '/' + filename + '_' + suffix
    end
    
  end
  
  def on_complete(status, options)
    count = IosAppEpfSnapshot.where(epf_full_feed_id: EpfFullFeed.last.id).count
    Slackiq.notify(webhook_name: :main, title: 'EPF Batch Completed', status: status, 'Apps Added' => count.to_s)
    `rm -rf /mnt/epf/*` if count > 1e6
  end
  
  def generate_weekly_newest_csv
    epf_full_feed_last = EpfFullFeed.last
    file_path = "/home/deploy/#{epf_full_feed_last.name}_weekly_newest.csv"
    
    newest_date = IosAppEpfSnapshot.order('itunes_release_date DESC').limit(1).first.itunes_release_date
    week_before_newest = newest_date - 6.days
    
    CSV.open(file_path, "w") do |csv|
      column_names = IosAppEpfSnapshot.column_names
      csv << column_names
      IosAppEpfSnapshot.where(epf_full_feed: epf_full_feed_last, itunes_release_date:  week_before_newest..newest_date).order('itunes_release_date DESC').each do |ss| 
        
        csv << ss.attributes.values_at(*column_names)
      end
    end
    
    true
  end
  
  def add_apps
    
    batch = Sidekiq::Batch.new
    batch.description = "EpfServiceAddAppsWorker" 
    batch.on(:complete, EpfServiceAddAppsWorkerCallback)
  
    batch.jobs do
      IosAppEpfSnapshot.where(epf_full_feed: EpfFullFeed.last).find_in_batches(batch_size: 1000).with_index do |b, index|
        li "Batch #{index}"
      
        ios_app_epf_snapshot_ids = b.map{ |ss| ss.id}
      
        EpfServiceAddAppsWorker.perform_async(ios_app_epf_snapshot_ids)
      end
    end
    
  end
  
  class EpfServiceAddAppsWorkerCallback
    
    def on_complete(status, options)
      Slackiq.notify(webhook_name: :main, title: 'EpfServiceAddAppsWorker Completed', status: status)
    end
    
  end

end