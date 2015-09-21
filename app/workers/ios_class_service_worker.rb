class IosClassServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk

  def perform(q)

  	in_cocoapods(q)

  end

  def save_known_ios_words(q)

  	kiw = KnownIosWords.find_by_word(q)

  	if kiw.nil? && in_apple_docs(q)

  		KnownIosWords.create(word: q)

  	end

  end

  def in_apple_docs?(q)

  	JSON.parse(open("https://developer.apple.com/search/search_data.php?q=#{q}&style=flat&results=500").read).any?{ |res| res['description'].downcase.include?(q) }

  end

  def in_cocoapods(q)

    cocoapods = JSON.parse(open("https://search.cocoapods.org/api/v1/pods.picky.hash.json?query=on%3Aios+#{q}&ids=20&offset=0&sort=quality").read).to_a

    first_words = cocoapods['allocations'][0][5].map{ |p| puts p['id'].split('-').first }

    first_word = first_words.max_by{ |p| first_words.count(p) }

    # test text similarity

    if first_word.downcase == q
      puts q.green
    else
      puts q.red
    end

  end

end