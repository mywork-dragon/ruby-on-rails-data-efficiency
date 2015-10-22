class IosClassService

	class << self

		def parse_classes

			class_dump = File.open('Zinio.classdump.txt').read

			clss = class_dump.scan(/(@property|@protocol|@interface|struct|_Bool|\(void\)|\(id\)|\(int\))(.*?)\n/m)

			# exclude_words = %w(ns ui categories table tab scroll search page library button zoom issue index image server theme purchase cl zinio)

			exclude_words = %w(zinio)

			the_classes = clss.map do |k, v|

				# str = v[/[^<]+/].strip

				str = v

				unless exclude_words.any?{ |s| str.downcase.include?(s) }

					# str = str.split(/[^\w\s]/).select(&:present?).count

					# str = str.gsub(/\((.*?)\)/m,'').gsub(/[^a-z0-9\s]/i,'').gsub('Bool','').gsub('Init','').gsub('init','').gsub('nonatomic','').gsub('dealloc','').gsub('retain','').gsub('readonly','').strip if str.present?

					# IosClassServiceWorker.new.perform(str)

					# words = str.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip unless str.present?

					str = str.gsub(/\((.*?)\)/m,'').gsub(/[^\w\s]/,' ').gsub('_',' ') if str.present?

					str


				end

			end

			the_classes.select(&:present?).uniq

		end


		def top_words

			parse_classes.each do |cls|

				# IosClassServiceWorker.new.perform(cls)

				# puts cls if cls.downcase.include? 'crittercism'

				puts cls.split(/[A-Z][a-z]/)

			end

			nil

		end


		def search_apple_docs

			parse_classes.each do |cls|

				IosClassServiceWorker.new.perform(cls)

			end

		end


	end

end