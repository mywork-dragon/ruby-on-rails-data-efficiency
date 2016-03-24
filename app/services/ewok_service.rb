# Service for the Ewok Chrome Extension
class EwokService

  KEY = 'db5be718bbaf446cf24e39d61c82e9c7'

  class << self

    def correct_key?(key)
      key == KEY
    end

    def app_id_and_store(url)
      if md = url.match(/itunes\.apple\.com\/.*id(\d+)/)
        app_identifier = md.captures.first
        ios_app = IosApp.find_by_app_identifier(app_identifier)
        return ios_app ? {id: ios_app.id, store: :ios} : nil
      elsif md = url.match(/play.google.com\/store\/apps\/details\?id=([^&]*)/)
        app_identifer = md.captures.first
        android_app = AndroidApp.find_by_app_identifier(app_identifier)
        return android_app ? {id: android_app.id, store: :android} : nil
      end
      nil
    end

    def app_url(url)
      ais = app_id_and_store(url)
      
      return nil if ais.nil?

      id = ais[:id]
      store = ais[:store]

      if store == :ios
        ret = "http://mightysignal.com/app/app#/app/ios/#{id}"
      elsif store == :android
        ret = "http://mightysignal.com/app/app#/app/android/#{id}" 
      end

      ret
    end

    def ios_app_url(id)
    end

    def android_app_url

    def store
      if 
    end

    def ios_app_in_db?
    end

    def android_app_in_db?
    end

    def app_page

    end

  end

end