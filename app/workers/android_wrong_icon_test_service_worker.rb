class AndroidWrongIconTestServiceWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: false

  def perform

    app_identifier = 'com.etermax.preguntados.lite'

    html = google_play_html(app_identifier)

    icon_url = icon_url_300x300(html)

    json = JSON.parse(Tor.get('http://wtfismyip.com/json'))
    ip = json['YourFuckingIPAddress']
    location = json['YourFuckingLocation']
    ip_location = "#{ip}; #{location}"[0..190]

    st = SidekiqTester.create!(test_string: icon_url, ip: ip_location)

    if !icon_url.include?('wBm0OacVBiFPAfxvrwuJcNWSuhfs1J7rr141r0wETQFhAhfGv29JzMC6W5i_vv8Zxw')
      filename = "trivia_crack_bad_html_#{st.id}"

      File.write("/home/deploy/#{filename}", html)

      Slackiq.message("Wrong Link!: id: #{st.id}")
    end
  end

  def google_play_html(app_identifier)
    url = "https://play.google.com/store/apps/details?id=#{app_identifier}"
    
    page = Tor.get(url)

    Nokogiri::HTML(page)

    # Rescues error if issue opening URL
    rescue => e
      case e
        when OpenURI::HTTPError
          return nil
        when URI::InvalidURIError
          return nil
        else
          raise e
    end
  end

  def icon_url_300x300(html)
    html.css('div.details-info .cover-image').first['src']
  end
  
end