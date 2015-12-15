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
