notes = ARGV[0]

puts "notes: #{notes}"

# what_to_echo = "hello"
#
# Dir.mkdir("dummy_folder")

notes_filename = friendly_filename(notes)
puts "notes_filename: #{notes_filename}"

#
# puts `echo #{what_to_echo} > dummy_folder/#{notes}.out`

BEGIN {
  def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
              .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
              .gsub(/\s+/, '_')
  end
}

