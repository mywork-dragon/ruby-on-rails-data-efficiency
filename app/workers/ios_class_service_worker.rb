class IosClassServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk

  def perform(q)

  	top_words(q)

  end



  def top_words(q)

    q.split(/(?=[A-Z])/).map(&:downcase).each do |word|

      iwo = IosWordOccurence.find_by_word(word)

      if iwo.nil?

        IosWordOccurence.create(word: word, count: 1)

      else

        iwo.count += 1

        iwo.save

      end

    end

  end










  def save_known_ios_words(q)

  	kiw = KnownIosWord.find_by_word(q)

  	if kiw.nil? && in_apple_docs?(q)

  		KnownIosWord.create(word: q)

  	end

  end

  def in_apple_docs?(q)

  	JSON.parse(open("https://developer.apple.com/search/search_data.php?q=#{q}&style=flat&results=500").read).any?{ |res| res['description'].downcase.include?(q) }

  end


  # def string(first_str = 'helloimacooldude', second_str = 'hellosometimesieatcheese')

  #   first_arr = first_str.downcase.split('')

  #   second_arr = second_str.downcase.split('')

  #   [first_arr, second_arr].each.with_index do |str, str_ind|

  #     stop_at = str.length

  #     double_letters = str.map.with_index do |letter, index|

  #       if index < stop_at - 1
          
  #         letter + str[index+1]

  #       end

  #     end

  #   end

  # end


  def in_cocoapods(q)

    failed_terms = []

    successful_terms = []

    words = q.gsub(/(message|binary|application|internal|custom|batch|through|viewed|view|event|for|thread|descriptor|unknown)/i,'')

    words = words.split(/(?=[A-Z])/)

    words_count = words.select{ |w| w.length > 1 }.count

    words.pop if words_count >= 3

    words.each.with_index do |word, index|

      index = words.count - index

      str = index.times.map do |i|

        words[i]

      end

      str = str.join

      if str.length >= 3

        # puts str

        # sleep 0.2

        next if failed_terms.include?(str) || successful_terms.include?(str)

        cocoapods = JSON.parse(open("https://search.cocoapods.org/api/v1/pods.picky.hash.json?query=on%3Aios+#{URI.escape(str)}&ids=20&offset=0&sort=quality").read).to_h

        if cocoapods['allocations'].present?

          pod = cocoapods['allocations'][0][5].select{|x| x['link'].exclude?('github.') }.sort_by{|x| x['id'].size }.first

          if pod.present?

            if str.similar(pod['id']) >= 80
              puts str.green
              puts "    => #{pod['id']}"
              puts "    => #{pod['link']}"

              successful_terms << str
              
              break

            else
              puts str.yellow

              failed_terms << str

            end

          else

            pod = cocoapods['allocations'][0][5].sort_by{|x| x['id'].size }.first

            return if pod['id'].blank?

            if str.similar(pod['id']) >= 80
              puts str.blue

              successful_terms << str
            else
              puts str.purple

              failed_terms << str
            end

          end

        else

          puts str.red

        end

        puts successful_terms

        puts failed_terms

      end






    end







    # q.split(/(?=[A-Z])/).each.with_index do |word, index|

    #   str = 

    #   cocoapods = JSON.parse(open("https://search.cocoapods.org/api/v1/pods.picky.hash.json?query=on%3Aios+#{URI.escape(str)}&ids=20&offset=0&sort=quality").read).to_h

    #   if cocoapods['allocations'].present?

    #     pod = cocoapods['allocations'][0][5].select{|x| x['link'].exclude?('github.') }.sort_by{|x| x['id'].size }.first

    #     if pod.present?

    #       if (first_word.similar(new_name) >= 80
    #         puts q.green
    #       else
    #         puts q.red
    #       end

    #     else

    #       pod = cocoapods['allocations'][0][5].sort_by{|x| x['id'].size }.first

    #       return if new_name.blank?

    #       if first_word.similar(pod['id']) >= 80
    #         puts q.blue
    #       else
    #         puts q.red
    #       end

    #     end

    #   else

    #     puts q.red

    #   end

    # end


    # first_word = first_words.max_by{ |p| first_words.count(p) }

    # return false if first_word.blank?

    # if q.similar(first_word) >= 80
    #   puts q.green
    # else
    #   puts q.red
    # end

    nil

  end

end