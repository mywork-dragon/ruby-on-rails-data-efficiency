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

end