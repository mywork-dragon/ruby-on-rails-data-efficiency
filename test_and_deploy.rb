#!/usr/bin/env ruby

test_output = %x(rake test)

last_line = test_output.lines.last
last_line.split(", ")
if !last_line.include?('0 failures')
  puts "Tests failed."
  abort
end
%x(cap production deploy)