class TestServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk

  def perform(q)

  	KnownIosWords.find_or_create_by(word: q) if in_app_docs?(q)

  end

  def in_app_docs?(q)

  	JSON.parse(open("https://developer.apple.com/search/search_data.php?q=#{q}&style=flat&results=500").read).any?{ |res| res['description'].downcase.include?(q) }

  end

end