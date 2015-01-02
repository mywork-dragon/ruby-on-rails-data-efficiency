test_output = %x(rake_test)

last_line = test_output.line.last
last_line.split(", ")
if !last_line.include?('0 failures')
  puts "Tests failed."
  abort
end
%x(cap production deploy)