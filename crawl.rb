if(ARGV.length != 2)
  puts "You need 2 arguments."
  puts "1st argument: Notes (must be unique)"
  puts "2nd argument: Number of Processes"
  abort
end

notes = ARGV[0]
num_processes = ARGV[1]

puts "notes: #{notes}"
puts "num_processes: #{num_processes}"
# puts

# what_to_echo = "hello"
#
# Dir.mkdir("dummy_folder")

notes_filename = friendly_filename(notes)
puts "notes_filename: #{notes_filename}"



# nohup bundle exec rake scraper:scrape_all SCRAPE_PERCENTAGE=50 SCRAPE_PAGE_NUMBER=0 SCRAPE_JOB_NOTES=notes RAILS_ENV=production > /dev/null 2>&1

#
# puts `echo #{what_to_echo} > dummy_folder/#{notes}.out`

BEGIN {
  
  def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
              .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
              .gsub(/\s+/, '_')
  end

}

