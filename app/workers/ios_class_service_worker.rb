class IosClassServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk

  def perform(q)

  	save_known_ios_words(q)

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

end