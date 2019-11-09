class ItunesTopChartsRankings
  include HTTParty
  include ProxyParty

  # from mightylib.rankings.hardcoded.categories import ios_categories
  IOS_CATEGORY_IDS = %w( 6011 7012 6010 7011 7014 7019 6013 7009 7016 6012 7018 7017
                         7001 6015 7003 7002 7005 7004 6014 6006 6007 6004 6005 6002
                         6003 6000 6001 7015 6018 6016 36 6008 6009 7013 6017 7006 6020
                         6021 6023 6024 6025 ).freeze

  # category:
  # 30 - paid (iphone)
  # 27 - free (iphone)
  # 38 - grossing (iphone)
  IOS_POPULARITY_TABS_INDEX = {
                                '30' => '0',
                                '27' => '1',
                                '38' => '2'
                              }.freeze

  ENDPOINT = 'https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewTop'.freeze

  BUCKET_NAME =

  class << self
    def request_for(storefront_id)
      IOS_CATEGORY_IDS.each do |category|  #first 2 for testing pursposes remove if forgot
        IOS_POPULARITY_TABS_INDEX.each do |popularity_id, tab_index| #first 2 for testing pursposes remove if forgot
          begin
            res = proxy_request { get(ENDPOINT, query: req_params(category, tab_index), headers: req_headers(storefront_id)) }
            # File.open(filename, 'w') { |f| f.write(get_csv(res.body)) }
            ranking_list = res.body.scan /<key>item-id<\/key><integer>(\d+)<\/integer>/
            csv_str = CSV.generate do |csv|
              ranking_list.flatten.map.with_index(1) { |app_id, rank|  csv << [app_id, rank, Time.now.to_i] }
            end

            filename = "#{storefront_id}_#{category}_#{popularity_id}_#{tab_index}_tmp.csv"
            MightyAws::S3.new.store(
              bucket: 'itunes-top-charts-rankings',
              key_path: filename,
              data_str: csv_str
            )
          rescue => e
            Bugsnag.notify(e)
          end
        end# IOS_CATEGORY_IDS
      end # File.open
      true
    end

    private

    def req_headers(storefront_id)
      {
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'en;q=1.0,fr;q=1.0,de;q=0.9,ja;q=0.9,nl;q=0.9,it;q=0.9,es;q=0.8,pt;q=0.8,pt-PT;q=0.8,da;q=0.7,fi;q=0.7,nb;q=0.7,sv;q=0.7,ko;q=0.6,zh-Hans;q=0.6,zh-Hant;q=0.6,ru;q=0.5,pl;q=0.5,tr;q=0.5,uk;q=0.5,ar;q=0.4,hr;q=0.4,cs;q=0.4,el;q=0.3,he;q=0.3,ro;q=0.3,sk;q=0.3,th;q=0.2,id;q=0.2,ms;q=0.2,en-GB;q=0.1,ca;q=0.1,hu;q=0.1,vi;q=0.1',
        'Connection': 'keep-alive',
        'Proxy-Connection': 'keep-alive',
        'User-Agent': 'iTunes-iPod/5.1.1 (3; 32GB; dt:25)',
        'X-Apple-Client-Application': 'Software',
        'X-Apple-Client-Versions': 'GameCenter/2.0',
        'X-Apple-Connection-Type': 'WiFi',
        'X-Apple-Partner': 'origin.0',
        'X-Apple-Store-Front': "#{storefront_id},4"
      }
    end

    def req_params(category, tab_index)
      # tab index = rankings type
      # free = 1
      # paid = 0
      # grossing = 2
      # seems to go from page 0 to 60 (1-> ~1500)
      {
        'selected-tab-index' => tab_index,
        'genreId' => category,
        'guid' => 'f54b115643bcabbec0cfa30af8c12561c26f5219',
        'top-ten-m' => 100 # O_O returns all ranked
      }
    end
  end

end
