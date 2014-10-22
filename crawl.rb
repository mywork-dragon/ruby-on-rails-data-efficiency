notes = ARGV[0]

puts "notes: #{notes}"

what_to_echo = "hello"

puts `echo #{what_to_echo} > dummy.out`