class TimeStampReader

  class << self
    def parse(time_stamp, time_zone_name = "Pacific Time (US & Canada)")
      self.new.parse(time_stamp, time_zone_name)
    end
  end

  # Can read timestamp from production log
  #
  # time_zone_name can be:
  # American Samoa
  # International Date Line West
  # Midway Island
  # Samoa
  # Hawaii
  # Alaska
  # Pacific Time (US & Canada)
  # Tijuana
  # Arizona
  # Chihuahua
  # Mazatlan
  # Mountain Time (US & Canada)
  # Central America
  # Central Time (US & Canada)
  # Guadalajara
  # Mexico City
  # Monterrey
  # Saskatchewan
  # Bogota
  # Eastern Time (US & Canada)
  # Indiana (East)
  # Lima
  # Quito
  # Caracas
  # Atlantic Time (Canada)
  # Georgetown
  # La Paz
  # Santiago
  # Montevideo
  # Newfoundland
  # Brasilia
  # Buenos Aires
  # Greenland
  # Mid-Atlantic
  # Azores
  # Cape Verde Is.
  # Casablanca
  # Dublin
  # Edinburgh
  # Lisbon
  # London
  # Monrovia
  # UTC
  # Amsterdam
  # Belgrade
  # Berlin
  # Bern
  # Bratislava
  # Brussels
  # Budapest
  # Copenhagen
  # Ljubljana
  # Madrid
  # Paris
  # Prague
  # Rome
  # Sarajevo
  # Skopje
  # Stockholm
  # Vienna
  # Warsaw
  # West Central Africa
  # Zagreb
  # Athens
  # Bucharest
  # Cairo
  # Harare
  # Helsinki
  # Istanbul
  # Jerusalem
  # Kyiv
  # Pretoria
  # Riga
  # Sofia
  # Tallinn
  # Vilnius
  # Baghdad
  # Kuwait
  # Minsk
  # Moscow
  # Nairobi
  # Riyadh
  # St. Petersburg
  # Volgograd
  # Tehran
  # Abu Dhabi
  # Baku
  # Muscat
  # Tbilisi
  # Yerevan
  # Kabul
  # Ekaterinburg
  # Islamabad
  # Karachi
  # Tashkent
  # Chennai
  # Kolkata
  # Mumbai
  # New Delhi
  # Sri Jayawardenepura
  # Kathmandu
  # Almaty
  # Astana
  # Dhaka
  # Novosibirsk
  # Urumqi
  # Rangoon
  # Bangkok
  # Hanoi
  # Jakarta
  # Krasnoyarsk
  # Beijing
  # Chongqing
  # Hong Kong
  # Irkutsk
  # Kuala Lumpur
  # Perth
  # Singapore
  # Taipei
  # Ulaanbaatar
  # Osaka
  # Sapporo
  # Seoul
  # Tokyo
  # Yakutsk
  # Adelaide
  # Darwin
  # Brisbane
  # Canberra
  # Guam
  # Hobart
  # Magadan
  # Melbourne
  # Port Moresby
  # Sydney
  # Vladivostok
  # New Caledonia
  # Solomon Is.
  # Auckland
  # Fiji
  # Kamchatka
  # Marshall Is.
  # Wellington
  # Chatham Is.
  # Nuku'alofa
  # Tokelau Is.
  def parse(time_stamp, time_zone_name)
    time_stamp.chomp!
    date_time = DateTime.parse(time_stamp)
    zone = ActiveSupport::TimeZone.new(time_zone_name)
    date_time.in_time_zone(zone)
  end

end