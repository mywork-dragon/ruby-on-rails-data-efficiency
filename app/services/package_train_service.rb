require 'open-uri'
require 'sanitize'

class PackageTrainService

  class << self

    def run
      AndroidPackage.where(identified: false).joins(:apk_snapshot).find_each do |package|
        words(package.package_name, package.id)
      end
    end

    def words(package, package_id)
      ActiveRecord::Base.logger.level = 1

      words = package.downcase.split(".").uniq

      puts "\nresults for #{package}\n------------\n"

      i = 0
      for word in words
          puts "\n##{i}\n#{word}\n"
          i += 1
      end

      puts "\nType `n` if not useful, `s` for skip, or # for correct result"
      print "\nResponse : "
      a = gets.chomp

      if a == 's'
        system('clear')
        return false
      elsif a == 'n'
        for word in words
          classify_word(word, "bad")
        end
        ap = AndroidPackage.find(package_id)
        ap.identified = true
        ap.not_useful = true
        ap.save!
      else
        p_by_name = AndroidPackage.where(package_name: package).find_each
        p_by_name.each do |p|
          i = 0
          for word in words
            category = if a.to_i == i then "good" else "bad" end
            classify_word(word, category)
            i += 1
          end
          p.identified = true
          p.save!
        end
      end

      puts "\n~~~~~~~~~~~~\n"

      system('clear')

      return false
    end

    def classify_word(word, category)
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


# Identify the company name from within the string, then do a fuzzy search against the company database. If there's a match, manually create the match. If not, do the google thing