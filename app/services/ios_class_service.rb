class IosClassService

	class << self

    def classify(app_name)

      ActiveRecord::Base.logger.level = 1

      class_names(app_name).each do |q|

        puts q

        res = code_search(q) || search(q)

        next if res.nil? || q.nil?

        # save sdk

        puts res

      end

      nil

    end

    def class_names(app_name)

      dump = File.open("../dumps/#{app_name}.classdump")

      dump.scan(/@interface (.*?) :/m).map{ |k,v| k }.uniq

    end

    def search(q)

      s = %w(sdk -ios-sdk -ios -sdk).map{|p| q+p } << q

      c = Cocoapod.find_by_name(s)

      c.name if c.present?

    end

    def code_search(q)

      c = CocoapodSourceData.find_by_name(q)

      c.cocoapod.name if c.present?

    end












  #   def search(app_name)

  #     ActiveRecord::Base.logger.level = 1

  #     sdks = []

  #     interface_names_from_class_dump(app_name).each do |query|

  #       q = query[1]

  #       result = active_source_data_search(q) || active_search(q)

  #       next if result.nil? || query.nil?

  #       sdks << [query[1], result]

  #     end

  #     sdk_list = File.open("../dumps/#{app_name}.sdks").read

  #     mixrank = sdk_list.split("\n")

  #     both = []

  #     mightysignal = []

  #     sdks.each do |sdk|

  #       # sdk = sdk

  #       if mixrank.any?{|x| sdk[1].downcase.include? x.downcase.gsub(' ','') }

  #         both << sdk

  #       else

  #         mightysignal << sdk

  #       end

  #     end

  #     puts "\n"

  #     puts "Both -> #{both.count}".blue

  #     both.each{|b| puts '     ' + b[1].green + ' => ' + b[0].green }

  #     puts "MightySignal -> #{mightysignal.count}".blue

  #     mightysignal.each{|m| puts '     ' + m[1].purple + ' => ' + m[0].purple }

  #     mixrank = mixrank.map{|x| x unless both.any?{|s| s[1].downcase.include? x.downcase.gsub(' ','') } }.compact

  #     puts "Mixrank -> #{mixrank.count}".blue

  #     mixrank.each{|m| puts '     ' + m.red }

  #     puts "\n"

  #     sdks.count

  #   end

		# def interface_names_from_class_dump(app_name)

  #     class_dump = File.open("../dumps/#{app_name}.classdump").read

		# 	names = class_dump.scan(/@interface (.*?) :/m).uniq

  #     queries = []

  #     names.each do |str, v|
        
  #       orig = str

  #       queries << [orig, str]

  #       # str_arr = str.split(/(?=[A-Z][a-z])/)

  #       # str_arr.length.downto(0) do |i|

  #       #   str = str_arr.select.with_index{|x,j|j<i}.compact.join

  #       #   if str != str.upcase

  #       #     queries << [orig, str]

  #       #   end

  #       # end

  #     end

  #     queries.uniq

		# end

  #   def active_search(query)

  #     cocoapod = Cocoapod.find_by_name([query, query + 'sdk', query + '-ios-sdk', query + '-ios', query + '-sdk'])

  #     cocoapod.name if cocoapod.present?

  #   end

  #   def active_source_data_search(query)

  #     cocoapod_source_data = CocoapodSourceData.find_by_name(query)

  #     cocoapod_source_data.cocoapod.name if cocoapod_source_data.present?

  #   end



	end

end