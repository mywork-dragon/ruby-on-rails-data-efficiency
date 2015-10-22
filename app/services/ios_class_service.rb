class IosClassService

	class << self

<<<<<<< HEAD

=======
		def parse_classes

			class_dump = File.open('Zinio.classdump.txt').read
>>>>>>> master

    def train

<<<<<<< HEAD
      nb = NaiveBayes.new(:sdk, :garbage)

      training_words = %w(
        AppsFlyerConnectionDelegate
        AppsFlyerTrackerDelegate
        AppsFlyerParameters
        FiksuAppstoreDetector
        FiksuDebugManager
        FiksuFMABridge
        GCDMulticastDelegate
      )

      # training_words = %w(
      #   SFHFKeychainUtils
      #   MyLibrary
      #   Spread
      #   WebViewController
      #   Stack
      #   Analytics
      #   shareSDK
      #   Flow
      #   AsyncImageView
      #   Async
      #   DDAbstract
      #   JSONAPI
      #   JSON
      #   Notification
      #   Fabric
      #   SQLitePersistentObject
      # )
=======
			# exclude_words = %w(ns ui categories table tab scroll search page library button zoom issue index image server theme purchase cl zinio)

			exclude_words = %w(zinio)

			the_classes = clss.map do |k, v|

				# str = v[/[^<]+/].strip

				str = v
>>>>>>> master

      training_words.each do |word|

<<<<<<< HEAD
        system "clear"

        parts = word.split(/(?=[A-Z][a-z])/)
=======
					# str = str.split(/[^\w\s]/).select(&:present?).count

					# str = str.gsub(/\((.*?)\)/m,'').gsub(/[^a-z0-9\s]/i,'').gsub('Bool','').gsub('Init','').gsub('init','').gsub('nonatomic','').gsub('dealloc','').gsub('retain','').gsub('readonly','').strip if str.present?

					# IosClassServiceWorker.new.perform(str)
>>>>>>> master

        parts.each.with_index do |part, index|

<<<<<<< HEAD
          puts "#{index}. #{part}"
=======
					str = str.gsub(/\((.*?)\)/m,'').gsub(/[^\w\s]/,' ').gsub('_',' ') if str.present?

					str


				end
>>>>>>> master

        end

<<<<<<< HEAD
        puts "\nWhich #s are good?"

        answer = gets.chomp

        answers = answer.split(//).map{ |x| x.strip.to_i }

        parts.each.with_index do |part, index|

          category = answers.include?(index) ? :sdk : :garbage

          nb.train(category, parts[index])

        end

      end

      nb

    end


    def classify(word: 'AppsFlyerConversionConnectionDelegate')

      nb = train

      parts = word.split(/(?=[A-Z][a-z])/)
      
      parts.map do |part|

        category = nb.classify(*part)

        category.first == :sdk ? part : nil

      end.compact.join

    end















    def search(app_name)


      @known_shit = Mighty.array('
         CocoaLumberjack: DDAbstractDatabaseLogger
         CocoaLumberjack: DDAbstractLogger
      ')



      ActiveRecord::Base.logger.level = 1

      sdks = []

      interface_names_from_class_dump(app_name).each do |query|

        result = active_search(query[1])

        next if result.nil? || query.nil?

        # substring = longest_common_substring(result, query)

        # sdks << query if substring.length == result.gsub(/ios|sdk|\-/i,'').length

        sdks << query

      end

      sdk_list = File.open("../dumps/#{app_name}.sdks").read

      mixrank = sdk_list.split("\n")

      both = []

      mightysignal = []

      sdks.each do |sdk|

        # sdk = sdk

        if mixrank.any?{|x| sdk[0].downcase.include? x.downcase.gsub(' ','') }

          both << sdk

        else

          mightysignal << sdk

        end

      end

      puts "\n"

      puts "Both -> #{both.count}".blue

      both.each{|b| puts '     ' + b[1].green + ' => ' + b[0].green }

      puts "MightySignal -> #{mightysignal.count}".blue

      mightysignal.each{|m| puts '     ' + m[1].purple + ' => ' + m[0].purple }

      mixrank = mixrank.map{|x| x unless both.any?{|s| s[0].downcase.include? x.downcase.gsub(' ','') } }.compact

      puts "Mixrank -> #{mixrank.count}".blue

      mixrank.each{|m| puts '     ' + m.red }

      puts "\n"

      sdks.count

    end

		def interface_names_from_class_dump(app_name)

      class_dump = File.open("../dumps/#{app_name}.classdump").read

			names = class_dump.scan(/@interface (.*?) :/m).uniq

      queries = []

      names.each do |str, v|
        
        orig = str

        queries << [orig, str]

        # str_arr = str.split(/(?=[A-Z][a-z])/)

        # str_arr.length.downto(0) do |i|

        #   str = str_arr.select.with_index{|x,j|j<i}.compact.join

        #   if str != str.upcase

        #     queries << [orig, str]

        #   end

        # end

      end

      queries.uniq
=======
			the_classes.select(&:present?).uniq

		end


		def top_words

			parse_classes.each do |cls|

				# IosClassServiceWorker.new.perform(cls)

				# puts cls if cls.downcase.include? 'crittercism'

				puts cls.split(/[A-Z][a-z]/)

			end

			nil
>>>>>>> master

		end

    def active_search(query)

      cocoapod = Cocoapod.find_by_name([query, query + 'sdk', query + '-ios-sdk', query + '-ios', query + '-sdk'])

      # cocoapod = Cocoapod.where("name LIKE '%#{query}%'").sort_by{|x| x.name.length }.first

      cocoapod.name if cocoapod.present?

    end

    def elastic_search(query)

      result = AppsIndex::Cocoapod.query(
        match: {
            name: query
        }
      ).limit(1)


      if !result.count.zero?

        attributes = result.first.attributes

        return attributes['name']

      end

      nil

    end


    def longest_common_substring(str1, str2)

      return nil if [str1, str2].any?(&:blank?)

      str1 = str1.downcase

      str2 = str2.downcase

      m = Array.new(str1.length){ [0] * str2.length }

      longest_length, longest_end_pos = 0,0

      (0..str1.length - 1).each do |x|

        (0..str2.length - 1).each do |y|

          if str1[x] == str2[y]

            m[x][y] = 1

            if (x > 0 && y > 0)

              m[x][y] += m[x-1][y-1]

            end

            if m[x][y] > longest_length

              longest_length = m[x][y]

              longest_end_pos = x

            end

          end

        end

      end

      return str1[longest_end_pos - longest_length + 1 .. longest_end_pos]

    end

    def remove_subs(sdks)

      sdks.map{ |sdk| sdk unless sdks.any?{|x| x.downcase.include?(sdk.downcase) && x.length > sdk.length } }.compact

    end


		def search_apple_docs

			parse_classes.each do |cls|

				IosClassServiceWorker.new.perform(cls)

			end

		end


	end

end