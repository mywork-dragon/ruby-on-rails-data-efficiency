class IosClassService

	class << self

		def search_apple_docs

			class_dump = File.open('../Zinio.classdump.txt').read

			clss = class_dump.scan(/(@property|@protocol|@interface|struct|_Bool|\(void\)|\(id\)|\(int\))(.*?)\n/m)

			exclude_words = %w(ns ui categories table tab scroll search page library button zoom issue index image server theme purchase cl zinio)

			clss.each do |k, v|

				str = v[/[^<]+/].strip

				unless exclude_words.any?{ |s| str.downcase.include?(s) }

					str = str.gsub(/\((.*?)\)/m,'').gsub(/[^a-z0-9\s]/i,'').gsub('Bool','').gsub('Init','').gsub('init','').strip.split(' ').first

					IosClassServiceWorker.new.perform(str)

					# words = str.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip unless str.present?

				end

			end

			nil

		end


	end

end