class IosClassService

	class << self

    def search

      # ActiveRecord::Base.logger.level = 1

      sdks = []

      interface_names = ['ASDFThisIsATestYo']

      interface_names.each do |str|

        # Cocoapod.find_by_name(["#{str}","#{str}sdk","#{str}-sdk","#{str}-ios-sdk","#{str}-ios"])

        str_arr = str.split(/(?=[A-Z])/)

        arr_len = str_arr.length

        arr_len.downto(0) do |i|

          puts str_arr.map{|x| x if str_arr.index(x) <= i }.compact.join

          # puts str_arr

          # puts i

          # puts str_arr.map{|x| str_arr[str_len - str_arr.index(x)] }.compact.join

          # puts str_arr.map{|x| str_len}

        end

      end

      nil

      # mixrank = %w(facebook flurry afnetworking ziparchive bolts crashlytics cocoalumberjack plcrashreporter parse crittercism appsflyer pinterest webtrends gigya coretextlabel)

      # sdks.each do |sdk|

      #   if mixrank.any?{|x| sdk.downcase.include? x.downcase }

      #     puts sdk.green

      #   else

      #     puts sdk.purple

      #   end

      # end

      # nil

    end

		def interface_names

			class_dump = File.open('../Zinio.classdump.txt').read

			class_dump.scan(/@interface (.*?) :/m).uniq

      # .map{ |k,v| i = 0; k.split(/(?=[A-Z])/).join }.uniq

      # .map{|p| i+=1 if p.length>1; i<=2 ? p : nil}

		end

    def elastic(query)

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


    def lcs(str1, str2)

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


	end


end