class IosClassService

	class << self

		def search

			class_dump = File.open('../Zinio.classdump.txt').read

			clss = class_dump.scan(/(@property|@protocol|@interface|struct|_Bool|\(void\)|\(id\)|\(int\))(.*?)\n/m)

			exclude_words = %w(ns ui categories table tab scroll search page library button zoom issue index image server theme purchase cl zinio)

			hash = Hash.new

			clss.each do |k, v|

				str = v[/[^<]+/].strip

				unless exclude_words.any?{ |s| str.downcase.include?(s) }

					str = str.gsub(/\((.*?)\)/m,'').gsub(/[^a-z0-9\s]/i,'').gsub('Bool','').gsub('Init','').gsub('init','').strip.split(' ').first

					next if str.blank?

					# first_word = str.split(/(?=[A-Z])/).first

					

				    # words = str.split(/(?=[A-Z])/).select{ |x| x.length > 1 }.map{ |x| x }

				    # first_word = words.first

				    # next if first_word.blank?

				    # # puts first_word

				    # hash[first_word] = [] if hash[first_word].nil?

				    # words.each do |word|

				    # 	hash[first_word] << word

				    # end

				  #   words.each do |word|

						# if word.present?

					 #    	if hash[first_word].blank?
						#     	hash[first_word] = [first_word]
						#     else
						#     	hash[first_word] << word if word != first_word
						#     end

						# end

				  #   end

					IosClassServiceWorker.new.perform(str)

					# puts str

					# words = str.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip unless str.present?

				end

			end

			# hash.map do |k,v|

			# 	counts = Hash.new -1

			# 	v.each do |word|
			# 	  counts[word] += 1
			# 	end

			# 	{k => counts}

			# end

			nil

		end


	end

end