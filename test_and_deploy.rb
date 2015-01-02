test_output = %x(rake_test)

last_line = test_output.line.last
last_line.split(", ")
abort if !last_line.include?('0 failures')

%x(cap production deploy)