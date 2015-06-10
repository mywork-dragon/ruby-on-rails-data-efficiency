require 'open-uri'
require 'sanitize'

class GoogleTrainService

  class << self

    def run
      AndroidPackage.where("android_package_tag_id != ?", 2).joins(:apk_snapshot).find_each do |package|
        # puts "#{package.package_name} ----- with id `#{package.apk_snapshot_id}`"
        search(package.package_name, package.id)
      end
    end

    def search(query, package_id)
      ActiveRecord::Base.logger.level = 1

      googleUrl = "http://www.google.com/search?q=#{query}"
      results = Nokogiri::HTML(open(googleUrl))

      res = res(results)

      for r in res
          puts "\n##{r['count']}\n#{r['url']}\n#{r['description']}\n"
      end

      puts "\nResults for : #{query}"
      puts "\nType `s` to skip, or `d` to delete"
      print "\nCorrect Result # : "
      a = gets.chomp

      if a == 's'
        return false
      elsif a == 'd'
        print "\nAre you sure you want to delete this? [y/n] "
        b = gets.chomp
        if b == 'y'
          AndroidPackage.destroy(package_id)
        else
          return false
        end
      elsif a.is_a? Integer
        for r in res
          category = if a.to_i == r['count'].to_i then "good" else "bad" end
          classify_word(r['description'], category)
        end
      end

      return false
    end

    def res(results)
      search_results = []
      i = 0
      for res in results.xpath("//li[@class=\"g\"]")
        url = res.xpath("./h3[@class=\"r\"]/a/@href").to_s.split("=")[1].to_s.split("&")[0]
        if url =~ URI::regexp
          description = res.xpath("./div[@class=\"s\"]/span[@class=\"st\"]")
          d = clean_text(description)
          search_results << { "count" => i, "url" => url, "description" => d }
          i += 1
        end
      end
      search_results
    end

    def clean_text(txt)
      str = Sanitize.clean(txt)
      str.gsub!(/.*?(?= ago ... )/im, "").gsub!(/(ago ... ).*?/im, "") if str.include? " ago ... "
      str
    end

    def classify_word(words, category)
      words = words.gsub(/[^0-9a-z ]/i, " ").downcase.split(" ").uniq
      for word in words
        wo = WordOccurence.where(word: word).each
        if wo.count == 0
          woc = WordOccurence.create(word: word)
          woc.good = 1 if category == "good"
          woc.bad = 1 if category == "bad"
          woc.save!
        elsif wo.count == 1
          wo.first.good += 1 if category == "good"
          wo.first.bad += 1 if category == "bad"
          wo.first.save!
        end
      end
    end
  end

end