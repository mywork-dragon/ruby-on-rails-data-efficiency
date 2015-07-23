class Mighty
	
	class << self


		def array(arr)
	        hash = Hash.new

	        curr_key = ''

	        i = 0

	        arr.split(' ').each do |w|
	            if w.present?
	                
	                if w.include? ':'
	                  curr_key = w.gsub(':','')
	                  hash[curr_key] = ''
	                elsif curr_key.blank?
	                  hash[i] = w
	                elsif hash[curr_key].blank?
	                  hash[curr_key] = w
	                elsif hash[curr_key].kind_of?(String)
	                  hash[curr_key] = [hash[curr_key]] << w
	                else
	                  hash[curr_key] = hash[curr_key] << w
	                end

	                i+=1

	            end 
	        end

	        hash
		end

		


	end

end
