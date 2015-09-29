class IosClassService

	class << self

    def lcs(str1 = "please, peter go swimming", str2 = "I’m peter goliswi")

      require 'matrix'

      str1 = str1.downcase.split('')
      str2 = str2.downcase.split('')

      columns = []

      str1.each do |char1|

        column = []

        str2.each do |char2|

          if char1 == char2

            column << 1

          else

            column << 0

          end

          # column << (char1 == char2) ? 1:0

        end

        columns << column

      end

      matrix = Matrix.columns(columns).to_a

      puts "\n"

      matrix.each{|m| puts m.inspect}

      puts "\n"

      # Matrix.rows(matrix).each(:diagonal)

      matrix.count.times.collect { |i| matrix[i][i] }

    end

    def search

      # ActiveRecord::Base.logger.level = 1

      sdks = interface_names.map do |str|

        # Cocoapod.find_by_name(["#{str}","#{str}sdk","#{str}-sdk","#{str}-ios-sdk","#{str}-ios"])

        elastic(str) if str.present?

      end.compact

      mixrank = %w(facebook flurry afnetworking ziparchive bolts crashlytics cocoalumberjack plcrashreporter parse crittercism appsflyer pinterest webtrends gigya coretextlabel)

      sdks.each do |sdk|

        if mixrank.any?{|x| sdk.downcase.include? x.downcase }

          puts sdk.green

        else

          puts sdk.purple

        end

      end

      nil

    end

		def interface_names

			class_dump = File.open('../Zinio.classdump.txt').read

			class_dump.scan(/@interface (.*?) :/m).map{ |k,v| i = 0; k.split(/(?=[A-Z])/).join }.uniq

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


	end


end