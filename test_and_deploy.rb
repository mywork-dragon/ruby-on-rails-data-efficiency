#!/usr/bin/env ruby

test_output = %x(rake test)

last_line = test_output.lines.last

puts test_output

#puts ""
#puts "last_line: #{last_line}"

last_line.split(", ")
if !last_line.include?('0 failures')
  abort
end
%x(cap production deploy)