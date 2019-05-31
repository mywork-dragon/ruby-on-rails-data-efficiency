def enable_logging
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

def disable_logging
  ActiveRecord::Base.logger = Logger.new(nil) 
end
