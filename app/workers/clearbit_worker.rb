class ClearbitWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :clearbit

  IOS_DEVELOPER_IDS = {
    "newyorklife.com"=>[102421], "ingrammicro.com"=>[], "csc.com"=>[18045], 
    "discover.com"=>[32529], "nscorp.com"=>[55383], "amgen.com"=>[107833], 
    "linkedin.com"=>[49183], "itw.com"=>[], "broadcom.com"=>[72957], 
    "tjx.com"=>[], "mondelezinternational.com"=>[], "wnr.com"=>[], 
    "ea.com"=>[94478], "bms.com"=>[209111], "salesforce.com"=>[33041], 
    "conagrafoods.com"=>[], "l-3com.com"=>[427038], "nuance.com"=>[34251], 
    "cinemark.com"=>[250774], "3m.com"=>[15188], "microsoft.com"=>[34621], "motorolasolutions.com"=>[53103], 
    "pfgc.com"=>[57720], "rockwellautomation.com"=>[37437], "avisbudgetgroup.com"=>[263726], 
    "allstate.com"=>[130127], "lennar.com"=>[335499], "cmc.com"=>[343232], "dominos.com"=>[152875, 33990], 
    "thrivent.com"=>[], "aecom.com"=>[369785], "avnet.com"=>[21497], "voya.com"=>[17641], "airproducts.com"=>[17722], 
    "thehartford.com"=>[], "citrix.com"=>[28729], "xerox.com"=>[33320], "google.com"=>[6864], "carmax.com"=>[197906], 
    "utc.com"=>[], "abbvie.com"=>[103178], "hiltonworldwide.com"=>[212603], "altria.com"=>[17065], 
    "ecolab.com"=>[571179], "hp.com"=>[42846], "unum.com"=>[390811], "baxter.com"=>[], 
    "hasbro.com"=>[120187], "fiserv.com"=>[33491], "dillards.com"=>[], "duke-energy.com"=>[17065], 
    "goodyear.com"=>[41271], "sealedair.com"=>[213261, 61593], "guardianlife.com"=>[48402], 
    "thermofisher.com"=>[52819], "ppg.com"=>[199026], "praxair.com"=>[489172], "pmi.com"=>[], 
    "wellcare.com"=>[206570], "wesco.com"=>[72779], "manpowergroup.com"=>[38270], "techdata.com"=>[16627], 
    "penskeautomotive.com"=>[], "cdw.com"=>[27595], "autoliv.com"=>[], "huntsman.com"=>[], 
    "stryker.com"=>[76785], "rrdonnelley.com"=>[], "adobe.com"=>[338], "usfoods.com"=>[], 
    "goo.gl"=>[6864], "youtube.com"=>[6864], "youtu.be"=>[6864], "yahoo.com"=>[73828], 
    "facebook.com"=>[37304], "fb.com"=>[37304], "facebook.co"=>[37304], "instagram.com"=>[98351], 
    "twitter.com"=>[268130], "zendesk.com"=>[74232], "helpshift.com"=>[], "wix.com"=>[73203], 
    "uservoice.com"=>[249774], "weebly.com"=>[99862], "wordpress.com"=>[58683], 
    "wordpress.org"=>[58683], "amazon.com"=>[8574], "desk.com"=>[33041], "bit.ly"=>[1557358], 
    "blogspot.com"=>[], "pinterest.com"=>[262604], "tumblr.com"=>[265243], "webs.com"=>[312507], 
    "sina.com.cn"=>[12712], "sina.com"=>[12712], "weibo.com"=>[12712], "naver.com"=>[99423], 
    "appspot.com"=>[], "apple.com"=>[47346], "itunes.com"=>[47346], "freshdesk.com"=>[39580], "paypal.com"=>[57360],
    "qq.com"=>[84000, 91496, 60230], "aol.com"=>[36017], "aim.com"=>[36017], "cocos2d-x.org"=>[], "github.com"=>[], 
    "strikingly.com"=>[280303], "about.me"=>[45453], "yolasite.com"=>[], "prudential.com"=>[298823], "bnymellon.com"=>[139393]
  } 

  ANDROID_DEVELOPER_IDS = {
    "utc.com"=>[26747], "linkedin.com"=>[708], "hp.com"=>[890, 34954, 35173, 34932], "csc.com"=>[214861], 
    "nscorp.com"=>[200722], "gannett.com"=>[16776], "tenneco.com"=>[], "bms.com"=>[158548], "statestreet.com"=>[], 
    "disney.com"=>[290], "bnymellon.com"=>[], "ibm.com"=>[16124, 78524], "johndeere.com"=>[26703], 
    "discover.com"=>[90970], "harman.com"=>[122917], "baxter.com"=>[], "sysco.com"=>[67474], 
    "cisco.com"=>[28676], "pmi.com"=>[205356], "cmc.com"=>[343232], "rrdonnelley.com"=>[], 
    "ea.com"=>[41], "hyatt.com"=>[255822], "walmart.com"=>[73228], "americanexpress.com"=>[22060], 
    "mmc.com"=>[597414], "conocophillips.com"=>[30317], "qualcomm.com"=>[3454], "thermofisher.com"=>[30746], 
    "internationalpaper.com"=>[243618, 238186], "3m.com"=>[150563], "iheartmedia.com"=>[826], 
    "ford.com"=>[85412], "motorolasolutions.com"=>[48032], "appliedmaterials.com"=>[], "juniper.net"=>[157458], 
    "pfgc.com"=>[], "univision.com"=>[4554], "fiserv.com"=>[149154], "cognizant.com"=>[170966], 
    "amgen.com"=>[268459], "abbott.com"=>[47449], "precast.com"=>[], "intel.com"=>[15750], 
    "symantec.com"=>[55271], "allstate.com"=>[39765], "avnet.com"=>[79990], "att.com"=>[809], 
    "adobe.com"=>[618], "adt.com"=>[142166], "aecom.com"=>[474312], "aflac.com"=>[211880], 
    "honeywell.com"=>[43095], "agcocorp.com"=>[110341], "metlife.com"=>[127590], 
    "mastercard.com"=>[46853], "charter.com"=>[12194], "thehartford.com"=>[], "oge.com"=>[], 
    "xerox.com"=>[95576], "parker.com"=>[50546], "pg.com"=>[], "kofc.org"=>[794696], 
    "hertz.com"=>[60534], "homedepot.com"=>[45340], "firstdata.com"=>[], "ecolab.com"=>[364826], 
    "huntingtoningalls.com"=>[], "micron.com"=>[], "stryker.com"=>[], "goodyear.com"=>[212037], 
    "newyorklife.com"=>[388011], "microsoft.com"=>[49], "avaya.com"=>[584954, 105864], "terex.com"=>[105500], 
    "popular.com"=>[137438], "fisglobal.com"=>[83344], "ingrammicro.com"=>[126481], "eversource.com"=>[], 
    "jacobs.com"=>[129112], "eastman.com"=>[374435], "duke-energy.com"=>[292355], "cbre.com"=>[541069], 
    "rsac.com"=>[], "heartlandpaymentsystems.com"=>[122016], "danaher.com"=>[30317], 
    "prudential.com"=>[533860], "hollyfrontier.com"=>[], "sandisk.com"=>[15849], "voya.com"=>[46624, 324781], 
    "caterpillar.com"=>[80628], "wellcare.com"=>[224529], "huntsman.com"=>[124365], "nuance.com"=>[2954], 
    "manpowergroup.com"=>[426846], "f5.com"=>[115581], "cablevision.com"=>[], "paypal.com"=>[901], 
    "ppg.com"=>[64383], "genpt.com"=>[61965], "microchip.com"=>[44100], "hanover.com"=>[], "hdsupply.com"=>[35626], 
    "pseg.com"=>[], "corning.com"=>[150798], "progressive.com"=>[90806], "target.com"=>[1710], "wnr.com"=>[], 
    "unum.com"=>[420234], "o-i.com"=>[], "google.com"=>[26], "goo.gl"=>[26], "youtube.com"=>[26], 
    "youtu.be"=>[26], "yahoo.com"=>[37], "facebook.com"=>[55], "fb.com"=>[55], "facebook.co"=>[55], 
    "instagram.com"=>[101], "twitter.com"=>[125], "zendesk.com"=>[83735], "helpshift.com"=>[], 
    "wix.com"=>[382764], "uservoice.com"=>[190377], "weebly.com"=>[47842], "wordpress.com"=>[15621], 
    "wordpress.org"=>[15621], "amazon.com"=>[8], "desk.com"=>[91892], "bit.ly"=>[649390], "blogspot.com"=>[], 
    "pinterest.com"=>[547], "tumblr.com"=>[331], "webs.com"=>[658726], "sina.com.cn"=>[71943], "sina.com"=>[71943], 
    "weibo.com"=>[71943], "naver.com"=>[108], "appspot.com"=>[], "apple.com"=>[426619], "itunes.com"=>[426619], 
    "freshdesk.com"=>[29398], "qq.com"=>[22669, 498, 23991], "aol.com"=>[16551], "aim.com"=>[16551], 
    "cocos2d-x.org"=>[], "github.com"=>[], "strikingly.com"=>[], "about.me"=>[343529], "yolasite.com"=>[]
  }

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def queue_ios_apps(user_base)
    IosApp.where(id: IosSnapshotAccessor.new.ios_app_ids_from_user_base(user_base)).each do |app|
      next if app.headquarters.any?
      ClearbitWorker.perform_async(:enrich_app, app.id, 'ios')
    end
  end

  def queue_android_apps(user_base)
    AndroidApp.where(user_base: user_base).each do |app|
      next if app.headquarters.any?
      ClearbitWorker.perform_async(:enrich_app, app.id, 'android')
    end
  end

  def queue_n_apps_for_enrichment(n)
    ios_apps = get_n_non_enriched_apps(n / 2, IosApp.count, 'ios') {|offset, limit| IosApp.where.not(:user_base => nil).order(:user_base).offset(offset).limit(limit)}
    android_apps = get_n_non_enriched_apps(n / 2, AndroidApp.count, 'android') {|offset, limit| AndroidApp.where.not(:user_base => nil).order(:user_base).offset(offset).limit(limit)}
    ios_apps.each {|app| ClearbitWorker.perform_async(:enrich_app, app.id, 'ios')}
    android_apps.each {|app| ClearbitWorker.perform_async(:enrich_app, app.id, 'android')}
    puts "Queued #{ios_apps.count} iOS Apps for enrichment."
    puts "Queued #{android_apps.count} Android Apps for enrichment."
    {'ios_apps' => ios_apps, 'android_apps' => android_apps}
  end

  def get_n_non_enriched_apps(n, limit, namespace)
    # Expects a block which accepts and offset and limit parameter
    # and returns apps.
    Sidekiq.redis do |connection|
      apps = []
      i = 0
      increment = n * 2
      while apps.count < n and i < limit
        yield(i, increment).each do |app|
          processed_key = "cb_enrich_app_marker:#{namespace}:#{app.id}"
          next if app.headquarters.any? or connection.exists(processed_key)
          connection.setex(processed_key, 60.days.to_i, 1)
          apps.append(app)
          if apps.count >= n
            break
          end
        end
        i += increment
      end
      apps
    end
  end

  def populate_domains
    DomainDatum.where(clearbit_id: nil).each do |datum|
      puts "Populating #{datum.domain}"
      begin
        company_data = Clearbit::Company.find(domain: datum.domain, stream: true)
        puts company_data
        datum.populate(company_data)
      rescue
      end
    end
  end 

  def flag_ios_websites
    IOS_DEVELOPER_IDS.each do |domain, ids|
      developer_website_ids = Website.where("url REGEXP '[\.\/]+#{domain}[/]?'").joins(:ios_developers_websites => :ios_developer).
      where.not('ios_developers.id' => ids).pluck('ios_developers_websites.id')
      IosDevelopersWebsite.where(id: developer_website_ids).update_all(is_valid: false)
    end
  end

  def flag_android_websites
    ANDROID_DEVELOPER_IDS.each do |domain, ids|
      developer_website_ids = Website.where("url REGEXP '[\.\/]+#{domain}[/]?'").joins(:android_developers_websites => :android_developer).
      where.not('android_developers.id' => ids).pluck('android_developers_websites.id')
      AndroidDevelopersWebsite.where(id: developer_website_ids).update_all(is_valid: false)
    end 
  end

  def populate_domain_datum 
    ClearbitContact.where(domain_datum_id: nil).each do |contact|
      puts "Doing contact #{contact.id}"
      next unless contact.website && contact.website.domain
      domain_datum = DomainDatum.find_or_create_by(domain: contact.website.domain)
      domain_datum.clearbit_contacts << contact unless domain_datum.clearbit_contacts.include?(contact)
    end
  end

  def enrich_app(app_id, platform)
    puts "Processing app #{app_id}"
    if platform == 'ios'
      app = IosApp.find(app_id)
      developer = app.ios_developer
      urls = [app.seller_url, app.support_url]
    else
      app = AndroidApp.find(app_id)
      developer = app.android_developer
      urls = [app.seller_url]
    end
    
    if developer.blank?
      puts "Could not find app developer #{app.id}"
      if platform == 'ios'
        AppStoreDevelopersWorker.new.perform(:create_by_ios_app_id, app_id)
      else
        GooglePlayDevelopersWorker.new.perform(:create_by_android_app_id, app_id)
      end
    end

    return unless developer

    urls.compact.each do |url|
      website = Website.find_or_create_by(url: url)
      developer.websites << website unless developer.websites.include?(website)
    end
    
    developer.websites.each do |website|
      domain = UrlHelper.url_with_domain_only(website.url)
      
      begin
        company_data = Clearbit::Company.find(domain: domain, stream: true)
        domain_datum = DomainDatum.find_or_create_by(domain: domain)
      ensure
        domain_datum ||= DomainDatum.find_or_create_by(domain: domain)
        domain_datum.populate(company_data) if company_data
        domain_datum.websites << website unless domain_datum.websites.include?(website)
      end
    end
  end
end
