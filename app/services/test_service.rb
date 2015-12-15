class TestService

	class << self

	  def reproduce(n = 100)
	  	Rails.application.eager_load!
	  	a = ActiveRecord::Base.descendants.map{|x| x.split(' ').first }
	  	a.each do |model|
	  		columns = model
	  	end
	  end

	end

end

# unless the error code is nil, don't do anything

# actual updated date
# download
# scan
# correct error codes

# account for when there is an error code 4, but there is also data





# ERROR CODES FOR ANDROID_CHECK_EXIST
# errors
#   null => no error
# 	0 => taken down
# 	1 => country problem
# 	2 => device problem
# 	3 => carrier problem
#   4 => couldn't find
#   5 => paid app



# ERROR CODES AND STATUSES FOR ANDROID_CHECK_STATUS
# statuses
#   0 => queueing
#   1 => downloading
#   2 => scanning
#   3 => successful scan
#   4 => failed
# errors
#   null => no error
# 	0 => error connecting with google
# 	1 => taken down
# 	2 => device problem
# 	3 => country problem
# 	4 => carrier problem

