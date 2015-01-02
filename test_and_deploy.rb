#!/usr/bin/env ruby

test_cmd = 'rake test'
 
last_line = nil
IO.popen(test_cmd).each do |line|
  puts line
  last_line = line
end.close # Without close, you won't be able to access $?
 
#puts "The command's exit code was: #{$?.exitstatus}"

last_line.split(", ")
if !last_line.include?('0 failures')
  abort
end

system('cap production deploy')