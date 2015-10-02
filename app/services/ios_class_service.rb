class IosClassService

	class << self

    def search(app_name)

      ActiveRecord::Base.logger.level = 1

      sdks = []

      interface_names_from_class_dump(app_name).each do |query|

        result = active_search(query)

        next if result.nil? || query.nil?

        # substring = longest_common_substring(result, query)

        # sdks << query if substring.length == result.gsub(/ios|sdk|\-/i,'').length

        sdks << result

      end

      sdk_list = File.open("../dumps/#{app_name}.sdks").read

      mixrank = sdk_list.split("\n")

      both = []

      mightysignal = []

      sdks.each do |sdk|

        if mixrank.any?{|x| sdk.downcase.include? x.downcase }

          both << sdk

        else

          mightysignal << sdk

        end

      end

      puts "\n"

      puts "Both -> #{both.count}".blue

      both.each{|b| puts '     ' + b.green }

      puts "MightySignal -> #{mightysignal.count}".blue

      mightysignal.each{|m| puts '     ' + m.purple }

      mixrank = mixrank.map{|x| x unless both.any?{|s| s.downcase.include? x.downcase } }.compact

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

        queries << str

        # str_arr = str.split(/(?=[A-Z][a-z])/)

        # str_arr.length.downto(0) do |i|

        #   str = str_arr.select.with_index{|x,j|j<i}.compact.join

        #   if str != str.upcase

        #     queries << str

        #   end

        # end

      end

      queries.uniq

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


	end

end