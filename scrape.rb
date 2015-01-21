if(ARGV.length < 2)
  puts "1st arg: Notes (must be unique)"
  puts "2nd arg: Max Number of Processes"
  puts "3rd arg: Number of Companies to Scrape"
  puts "4th arg (opt): source_only"
  abort
end

options = {}

notes = ARGV[0]
num_processes = ARGV[1].to_i
count = ARGV[2]

scrape_option = nil

if count == "all"
  scrape_option = :scrape_all
elsif count.to_i.to_s == count #is a number
  scrape_option = :scrape_some
elsif count == "custom"
  scrape_option = :scrape_custom
else
  puts "3rd argument must be a number or \"all\""
  abort
end

source_only = "false"
source_only = "true " if ARGV[3] == "source_only"

directory_name = friendly_filename(notes)

scrape_job_creation_success = system "bundle exec rake scraper:create_scrape_job SCRAPE_JOB_NOTES=\"#{directory_name}\" RAILS_ENV=production"

abort if !scrape_job_creation_success

directory_path = "/home/deploy/scrape_logs/#{directory_name}"

Dir.mkdir(directory_path)

num_processes.times do |process_num|

  log_path = "#{directory_path}/#{process_num}.log"

  scrape_count_env = ""
  rake_task = ""
  if scrape_option == :scrape_some
    scrape_count_env = "SCRAPE_COUNT=#{count} "
    rake_task = "scrape_some"
  elsif scrape_option == :scrape_custom
    rake_task = "scrape_bizible_job2"
  else
    rake_task = "scrape_all"
  end


  command = "nohup bundle exec rake scraper:#{rake_task} #{scrape_count_env}SCRAPE_PROCESSES=#{num_processes} SCRAPE_PAGE_NUMBER=#{process_num} SCRAPE_JOB_NOTES=\"#{directory_name}\" SOURCE_ONLY=#{source_only} RAILS_ENV=production > #{log_path} &"

  # puts "log_path: #{log_path}"
  # puts "command: #{command}"
  # puts ""

  success = system(command)

  if success
    puts "Process #{process_num} running!"
  else
    puts "Error: Process #{process_num} failed to run."
  end

end

BEGIN {

  def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
              .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
              .gsub(/\s+/, '_')
  end

}

