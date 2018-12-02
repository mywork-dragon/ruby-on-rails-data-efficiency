module WelcomeHelper
  def store_to_platform store
    dictionary = {'google-play': 'android', 'ios': 'ios'}
    dictionary[store.to_sym]
  end
end
