class IosClassService

	class << self


    def tree

      class_dump = File.open('../Zinio.classdump.txt').read

      names = class_dump.scan(/@interface(.*?)$/)

      names.each do |name, v|

        if name[/: (.*?)$/,1].include? "NSObject"

          mixrank = %w(
            facebook
            flurry
            afnetworking
            ziparchive
            bolts
            crashlytics
            cocoalumberjack
            plcrashreporter
            parse
            crittercism
            appsflyer
            pinterest
            webtrends
            gigya
            coretextlabel
          )

          if mixrank.any?{|x| name.downcase.include? x.downcase }

            puts name.green

          end

        end

      end

      # names
      nil

    end
















    def search

      # ActiveRecord::Base.logger.level = 1

      sdks = []

      interface_names_from_class_dump.each do |query|

        # include wildcard and left edge

        result = elastic_search(query)

        next if result.nil? || query.nil?

        substring = longest_common_substring(result, query)

        sdks << query if substring.length == result.gsub(/ios|sdk|\-/i,'').length

      end

      sdks = remove_subs(sdks)



      # sdks.each do |sdk|

      #   puts sdk

      # end

      mixrank = %w(
        facebook
        flurry
        afnetworking
        ziparchive
        bolts
        crashlytics
        cocoalumberjack
        plcrashreporter
        parse
        crittercism
        appsflyer
        pinterest
        webtrends
        gigya
        coretextlabel
      )

      i = 1

      sdks.each do |sdk|

        if mixrank.any?{|x| sdk.downcase.include? x.downcase }

          puts "#{i}. #{sdk.green}"

          i+=1

        else

          puts sdk.purple

        end

      end

      nil

      sdks

    end

		def interface_names_from_class_dump

			class_dump = File.open('../Zinio.classdump.txt').read

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