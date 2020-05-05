class WelcomeController < ApplicationController
  include AppsHelper
  include SeoLinks

  before_action :retrieve_canonical_url
  before_action :retrieve_prev_next_url, only: [:top_ios_sdks, :top_android_sdks]

  protect_from_forgery except: :contact_us
  caches_action :top_ios_sdks, :top_android_sdks, :top_android_apps, :top_ios_apps, cache_path: Proc.new {|c| c.request.url}, expires_in: 24.hours, layout: false

  layout "marketing"

  def index
    @apps = IosApp.where(app_identifier: IosApp::WHITELISTED_APPS).to_a.shuffle

    @logos = [
        #{image: 'ghostery.png', width: 150},
        #{image: 'fiksu.png', width: 135},
        #{image: 'radiumone.png', width: 190},
        #{image: 'swrve.png', width: 150},
        #{image: 'mparticle.png', width: 180},
        # {image: 'tune.png', width: 135},
        {image: 'amplitude.png', width: 170},
        # {image: 'microsoft.png', width: 160},
        # {image: 'ironsrc.png', width: 170},
        #{image: 'vungle.png', width: 125},
        #{image: 'realm.png', width: 135},
        #{image: 'neumob.png', width: 170},
        # {image: 'yahoo.png', width: 165},
        # {image: 'appsflyer.png', width: 180},
        {image: 'leanplum.png', width: 180},
        {image: 'mixpanel.png', width: 160},
        {image: 'zendesk.png', width: 170},
        {image: 'adobe.png', width: 160}
    ].each {|logo| logo[:image] = '/lib/images/logos/' + logo[:image]}.sample(5)

    @funnel_icon = icons_folder + 'funnel.svg'
    @networking_icon = icons_folder + 'networking.svg'
    @team_icon = icons_folder + 'team.svg'
    @target_icon = icons_folder + 'target.svg'

    @abm4m_post_0 = buttercms_post_path('introducing-abm4m-account-based-marketing-for-mobile')
    @abm_blog_icon = graphics_folder + 'mightysignal_plus_salesforce_equals.png'
  end

  def search_apps
    query = params['query']

    result_ids = AppsIndex.query(
        multi_match: {
            query: query,
            fields: ['name.title^2', 'seller_url', 'seller'],
            type: 'phrase_prefix',
            max_expansions: 50,
        }
    ).boost_factor(
        3,
        filter: {term: {user_base: 'elite'}}
    ).boost_factor(
        2,
        filter: {term: {user_base: 'strong'}}
    ).boost_factor(
        1,
        filter: {term: {user_base: 'moderate'}}
    )
    result_ids = result_ids.limit(10)

    apps = result_ids.map do |result|
      id = result.attributes["id"]
      type = result._data["_type"]
      app = type == "ios_app" ? IosApp.find(id) : AndroidApp.find(id)
      {
          name: app.name,
          icon: app.icon_url,
          platform: app.platform,
          app_identifier: app.app_identifier,
          publisher: app.publisher.try(:name),
      }
    end

    render json: apps
  end

  def ios_app_sdks
    newest_snapshot = IosAppRankingSnapshot.last_valid_snapshot
    app_ids = IosApp.joins(:ios_app_rankings).where(ios_app_rankings: {ios_app_ranking_snapshot_id: newest_snapshot.id}).pluck(:app_identifier)
    if request.format.js? && app_ids.include?(params[:app_identifier].to_i)
      @app = IosApp.find_by_app_identifier(params[:app_identifier])
      @sdks = @app.tagged_sdk_response(true)
    elsif !IosApp::WHITELISTED_APPS.include?(params[:app_identifier].to_i)
      return redirect_to action: :index
    else
      @app = IosApp.find_by_app_identifier(params[:app_identifier])
      sdk_response = @app.sdk_history
      @installed_sdks = sdk_response[:installed_sdks]
      @uninstalled_sdks = sdk_response[:uninstalled_sdks]
      # remove pinterest from Etsy's uninstalled
      if @app.app_identifier == 477128284
        @uninstalled_sdks.shift
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def app_page
    @platform = params[:platform] == 'ios' ? 'ios' : 'android'
    app_identifier = params[:app_identifier]
    @app = "#{@platform.capitalize}App".constantize.find_by!(app_identifier: app_identifier)
    #@json_app = apps_hot_store.read(@platform, @app.id)
    #@json_publisher = publisher_hot_store.read(@platform, @app&.publisher&.id)
    @json_app = {"in_app_purchase_max"=>399, "description"=>"Network printer driver for Android. Directly print your photos from your Android device over your WIFI network. No need to install anything on your PC!<br><br>Lets you print from all printing enabled Android applications (e.g. browser, image gallery, office applications).<br><br>After first install, you have to enable  the zenofx.com PrintBot service. In the PrintBot GUI, use Menu -> Service settings. If you have any problems setting up, please use the integrated setup help (Menu -> Help).<br><br>PrintBot is now completely integrated with Android printing. For adding static (not automatically detected) printers please use \"Static printers\" from the PrintBot menu.<br><br>- Supports more than 5.000 printer models from all leading manufacturers (e.g. HP, Canon, Epson, Lexmark, Brother, Samsung). Works with most Airprint™ enabled printers.<br><br>- Supports printing over JetDirect, LPR and IPP protocol.<br><br>- Auto detect Bonjour printers<br><br>- Free version allows printing of 3 images or PDF documents per month (after that, a watermark is added on each page). PDFs are restricted to 3 pages.<br><br>- Pro version allows unlimited printing.", "versions_history"=>[{"version"=>"Varies with device", "released"=>"2016-08-19"}, {"version"=>"Varies with device", "released"=>"2017-06-11"}, {"version"=>"Varies with device", "released"=>"2017-06-25"}, {"version"=>"Varies with device", "released"=>"2017-06-29"}, {"version"=>"Varies with device", "released"=>"2017-07-09"}, {"version"=>"Varies with device", "released"=>"2017-07-14"}, {"version"=>"Varies with device", "released"=>"2018-01-01"}, {"version"=>"Varies with device", "released"=>"2018-01-03"}, {"version"=>"Varies with device", "released"=>"2018-06-29"}, {"version"=>"5.0.2", "released"=>"2018-07-10"}, {"version"=>"5.0.4", "released"=>"2018-07-23"}, {"version"=>"5.1.0", "released"=>"2019-08-12"}, {"version"=>"5.1.0", "released"=>"2019-10-05"}, {"version"=>"5.1.2", "released"=>"2019-10-12"}, {"version"=>"5.1.2", "released"=>"2019-10-22"}, {"version"=>"5.1.3", "released"=>"2019-11-10"}, {"version"=>"5.1.3", "released"=>"2010-12-28"}], "first_scraped"=>"2010-12-28", "user_base"=>"elite", "taken_down"=>false, "in_app_purchases"=>true, "categories"=>[{"name"=>"Productivity", "id"=>"PRODUCTIVITY"}], "current_version_release_date"=>"2019-11-10", "all_version_rating"=>3.3, "download_regions"=>[nil], "all_version_ratings_count"=>6239, "downloads_max"=>5000000, "icon_url"=>"https://lh3.googleusercontent.com/3QritaQAiJWHECI_Bw41FLfEZMSl4HOptaOFea-imXnjje9-_3GfrNYxuwDEg54H1L4", "required_android_version"=>"4.4 and up", "publisher"=>{"id"=>57040, "name"=>"zenofx.com", "platform"=>"android"}, "app_identifier"=>"net.jsecurity.printbot", "google_play_id"=>"net.jsecurity.printbot", "id"=>172999, "first_scanned_date"=>"2015-11-30T02:50:27Z", "name"=>"PrintBot", "seller_url"=>"http://zenofx.com/printbot/", "permissions"=>["android.permission.ACCESS_WIFI_STATE", "android.permission.CHANGE_WIFI_MULTICAST_STATE", "android.permission.INTERNET", "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WAKE_LOCK", "com.android.vending.BILLING"], "seller"=>"zenofx.com", "price"=>0, "mobile_priority"=>"low", "ratings_history"=>[{"start_date"=>"2016-09-20T12:54:23.000-07:00", "stop_date"=>"2016-09-20T12:54:23.000-07:00", "ratings_all_count"=>5785, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-09-24T14:23:36.000-07:00", "stop_date"=>"2016-09-24T14:23:36.000-07:00", "ratings_all_count"=>5787, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-10-01T19:57:38.000-07:00", "stop_date"=>"2016-10-01T19:57:38.000-07:00", "ratings_all_count"=>5795, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-10-09T15:16:21.000-07:00", "stop_date"=>"2016-10-15T22:13:17.000-07:00", "ratings_all_count"=>5802, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-10-22T19:48:19.000-07:00", "stop_date"=>"2016-10-22T19:48:19.000-07:00", "ratings_all_count"=>5805, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-10-25T16:10:48.000-07:00", "stop_date"=>"2016-10-29T01:32:14.000-07:00", "ratings_all_count"=>5810, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-11-06T12:17:55.000-08:00", "stop_date"=>"2016-11-06T12:17:55.000-08:00", "ratings_all_count"=>5813, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-11-20T08:54:27.000-08:00", "stop_date"=>"2016-11-20T08:54:27.000-08:00", "ratings_all_count"=>5815, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-11-11T15:52:20.000-08:00", "stop_date"=>"2016-11-28T10:55:07.000-08:00", "ratings_all_count"=>5814, "ratings_all_stars"=>3.45}, {"start_date"=>"2016-12-04T22:23:37.000-08:00", "stop_date"=>"2016-12-04T22:23:37.000-08:00", "ratings_all_count"=>5819, "ratings_all_stars"=>3.44}, {"start_date"=>"2016-12-11T01:40:34.000-08:00", "stop_date"=>"2016-12-11T01:40:34.000-08:00", "ratings_all_count"=>5823, "ratings_all_stars"=>3.44}, {"start_date"=>"2016-12-19T16:05:02.000-08:00", "stop_date"=>"2016-12-19T18:31:27.000-08:00", "ratings_all_count"=>5828, "ratings_all_stars"=>3.44}, {"start_date"=>"2016-12-26T20:01:51.000-08:00", "stop_date"=>"2016-12-26T20:01:51.000-08:00", "ratings_all_count"=>5829, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-01-02T11:35:53.000-08:00", "stop_date"=>"2017-01-02T11:35:53.000-08:00", "ratings_all_count"=>5831, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-01-11T17:15:29.000-08:00", "stop_date"=>"2017-01-11T17:15:29.000-08:00", "ratings_all_count"=>5838, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-01-16T13:12:36.000-08:00", "stop_date"=>"2017-01-16T13:12:36.000-08:00", "ratings_all_count"=>5839, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-01-23T12:25:51.000-08:00", "stop_date"=>"2017-01-23T12:25:51.000-08:00", "ratings_all_count"=>5845, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-01-30T10:07:07.000-08:00", "stop_date"=>"2017-01-30T10:07:07.000-08:00", "ratings_all_count"=>5848, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-02-06T10:04:13.000-08:00", "stop_date"=>"2017-02-06T10:04:13.000-08:00", "ratings_all_count"=>5855, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-02-13T10:11:42.000-08:00", "stop_date"=>"2017-02-18T15:42:00.000-08:00", "ratings_all_count"=>5859, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-03-06T12:24:26.000-08:00", "stop_date"=>"2017-03-06T12:24:26.000-08:00", "ratings_all_count"=>5864, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-03-14T14:45:43.000-07:00", "stop_date"=>"2017-03-14T14:45:43.000-07:00", "ratings_all_count"=>5869, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-03-20T11:06:10.000-07:00", "stop_date"=>"2017-04-03T11:03:00.000-07:00", "ratings_all_count"=>5872, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-03-27T11:04:23.000-07:00", "stop_date"=>"2017-04-10T11:04:01.000-07:00", "ratings_all_count"=>5871, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-04-17T11:48:49.000-07:00", "stop_date"=>"2017-04-19T20:14:40.000-07:00", "ratings_all_count"=>5878, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-04-23T18:09:13.000-07:00", "stop_date"=>"2017-04-25T20:35:42.000-07:00", "ratings_all_count"=>5879, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-04-27T06:12:26.000-07:00", "stop_date"=>"2017-04-30T17:46:46.000-07:00", "ratings_all_count"=>5881, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-05-08T16:19:27.000-07:00", "stop_date"=>"2017-05-09T04:05:33.000-07:00", "ratings_all_count"=>5884, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-05-11T05:42:15.000-07:00", "stop_date"=>"2017-05-11T05:42:15.000-07:00", "ratings_all_count"=>5885, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-05-16T17:16:27.000-07:00", "stop_date"=>"2017-05-16T17:16:27.000-07:00", "ratings_all_count"=>5889, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-05-18T10:24:56.000-07:00", "stop_date"=>"2017-05-18T10:24:56.000-07:00", "ratings_all_count"=>5891, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-05-25T05:49:03.000-07:00", "stop_date"=>"2017-05-25T05:49:03.000-07:00", "ratings_all_count"=>5898, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-06-01T05:46:04.000-07:00", "stop_date"=>"2017-06-01T05:46:04.000-07:00", "ratings_all_count"=>5900, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-06-08T21:11:47.000-07:00", "stop_date"=>"2017-06-08T21:11:47.000-07:00", "ratings_all_count"=>5903, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-06-15T05:45:08.000-07:00", "stop_date"=>"2017-06-15T05:45:08.000-07:00", "ratings_all_count"=>5910, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-06-22T05:42:27.000-07:00", "stop_date"=>"2017-06-22T05:42:27.000-07:00", "ratings_all_count"=>5912, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-06-29T05:45:44.000-07:00", "stop_date"=>"2017-06-29T05:45:44.000-07:00", "ratings_all_count"=>5916, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-07-06T05:43:25.000-07:00", "stop_date"=>"2017-07-06T05:43:25.000-07:00", "ratings_all_count"=>5918, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-07-13T05:40:47.000-07:00", "stop_date"=>"2017-07-13T05:40:47.000-07:00", "ratings_all_count"=>5919, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-07-14T15:42:40.000-07:00", "stop_date"=>"2017-07-14T15:42:40.000-07:00", "ratings_all_count"=>5920, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-07-16T17:41:12.000-07:00", "stop_date"=>"2017-07-23T17:43:29.000-07:00", "ratings_all_count"=>5921, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-07-27T05:42:18.000-07:00", "stop_date"=>"2017-07-27T05:42:18.000-07:00", "ratings_all_count"=>5922, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-07-30T17:39:07.000-07:00", "stop_date"=>"2017-07-30T17:39:07.000-07:00", "ratings_all_count"=>5927, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-08-06T17:40:05.000-07:00", "stop_date"=>"2017-08-06T17:40:05.000-07:00", "ratings_all_count"=>5929, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-08-10T05:37:06.000-07:00", "stop_date"=>"2017-08-10T05:37:06.000-07:00", "ratings_all_count"=>5931, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-08-03T05:37:52.000-07:00", "stop_date"=>"2017-08-13T17:39:44.000-07:00", "ratings_all_count"=>5928, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-08-17T05:42:51.000-07:00", "stop_date"=>"2017-08-17T05:42:51.000-07:00", "ratings_all_count"=>5930, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-08-20T17:42:07.000-07:00", "stop_date"=>"2017-08-24T05:45:46.000-07:00", "ratings_all_count"=>5932, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-08-27T17:42:49.000-07:00", "stop_date"=>"2017-08-27T17:42:49.000-07:00", "ratings_all_count"=>5934, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-08-31T05:50:40.000-07:00", "stop_date"=>"2017-09-03T17:46:35.000-07:00", "ratings_all_count"=>5935, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-09-06T15:47:07.000-07:00", "stop_date"=>"2017-09-07T07:56:38.000-07:00", "ratings_all_count"=>5936, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-09-10T17:49:23.000-07:00", "stop_date"=>"2017-09-10T17:49:23.000-07:00", "ratings_all_count"=>nil, "ratings_all_stars"=>nil}, {"start_date"=>"2017-09-14T05:46:32.000-07:00", "stop_date"=>"2017-09-14T05:46:32.000-07:00", "ratings_all_count"=>5937, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-09-17T17:36:59.000-07:00", "stop_date"=>"2017-09-17T17:36:59.000-07:00", "ratings_all_count"=>5940, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-09-21T05:41:18.000-07:00", "stop_date"=>"2017-09-28T05:43:49.000-07:00", "ratings_all_count"=>5941, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-01T17:37:57.000-07:00", "stop_date"=>"2017-10-01T17:37:57.000-07:00", "ratings_all_count"=>5943, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-05T05:41:00.000-07:00", "stop_date"=>"2017-10-05T05:41:00.000-07:00", "ratings_all_count"=>5946, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-08T17:38:34.000-07:00", "stop_date"=>"2017-10-12T05:43:23.000-07:00", "ratings_all_count"=>5948, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-15T17:38:50.000-07:00", "stop_date"=>"2017-10-15T17:38:50.000-07:00", "ratings_all_count"=>5951, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-19T06:05:54.000-07:00", "stop_date"=>"2017-10-19T06:05:54.000-07:00", "ratings_all_count"=>5952, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-22T17:35:31.000-07:00", "stop_date"=>"2017-10-22T17:35:31.000-07:00", "ratings_all_count"=>5955, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-26T05:43:30.000-07:00", "stop_date"=>"2017-10-26T05:43:30.000-07:00", "ratings_all_count"=>5956, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-10-29T17:35:35.000-07:00", "stop_date"=>"2017-10-29T17:35:35.000-07:00", "ratings_all_count"=>5958, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-11-02T05:43:03.000-07:00", "stop_date"=>"2017-11-05T16:49:51.000-08:00", "ratings_all_count"=>5960, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-11-09T04:46:40.000-08:00", "stop_date"=>"2017-11-09T18:52:19.000-08:00", "ratings_all_count"=>5961, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-11-12T16:34:18.000-08:00", "stop_date"=>"2017-11-15T20:20:47.000-08:00", "ratings_all_count"=>5962, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-11-20T05:38:39.000-08:00", "stop_date"=>"2017-11-20T05:38:39.000-08:00", "ratings_all_count"=>5965, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-11-23T05:36:50.000-08:00", "stop_date"=>"2017-11-23T05:36:50.000-08:00", "ratings_all_count"=>5969, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-12-04T09:11:51.000-08:00", "stop_date"=>"2017-12-04T09:11:51.000-08:00", "ratings_all_count"=>5974, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-11-27T05:46:33.000-08:00", "stop_date"=>"2017-12-07T09:11:23.000-08:00", "ratings_all_count"=>5972, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-11-30T15:34:06.000-08:00", "stop_date"=>"2017-12-12T08:41:52.000-08:00", "ratings_all_count"=>5973, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-12-14T19:01:33.000-08:00", "stop_date"=>"2017-12-14T19:01:33.000-08:00", "ratings_all_count"=>5975, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-12-18T09:21:09.000-08:00", "stop_date"=>"2017-12-18T09:21:09.000-08:00", "ratings_all_count"=>5978, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-12-21T09:30:06.000-08:00", "stop_date"=>"2017-12-21T09:30:06.000-08:00", "ratings_all_count"=>5981, "ratings_all_stars"=>3.44}, {"start_date"=>"2017-12-25T09:19:10.000-08:00", "stop_date"=>"2018-01-01T09:24:47.000-08:00", "ratings_all_count"=>5985, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-01-04T09:41:19.000-08:00", "stop_date"=>"2018-01-04T09:41:19.000-08:00", "ratings_all_count"=>5987, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-01-08T09:37:42.000-08:00", "stop_date"=>"2018-01-11T10:57:30.000-08:00", "ratings_all_count"=>5992, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-01-15T10:10:44.000-08:00", "stop_date"=>"2018-01-15T10:10:44.000-08:00", "ratings_all_count"=>5997, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-01-18T10:50:08.000-08:00", "stop_date"=>"2018-01-18T10:50:08.000-08:00", "ratings_all_count"=>5998, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-01-22T09:43:35.000-08:00", "stop_date"=>"2018-01-22T09:43:35.000-08:00", "ratings_all_count"=>6002, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-01-25T10:09:41.000-08:00", "stop_date"=>"2018-01-25T10:09:41.000-08:00", "ratings_all_count"=>6005, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-01-29T10:10:56.000-08:00", "stop_date"=>"2018-01-29T10:10:56.000-08:00", "ratings_all_count"=>6008, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-02-01T11:00:41.000-08:00", "stop_date"=>"2018-02-01T11:00:41.000-08:00", "ratings_all_count"=>6009, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-02-05T10:51:28.000-08:00", "stop_date"=>"2018-02-05T10:51:28.000-08:00", "ratings_all_count"=>6010, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-02-08T11:09:46.000-08:00", "stop_date"=>"2018-02-08T11:09:46.000-08:00", "ratings_all_count"=>6011, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-02-12T10:44:51.000-08:00", "stop_date"=>"2018-02-12T10:44:51.000-08:00", "ratings_all_count"=>6012, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-02-15T11:40:16.000-08:00", "stop_date"=>"2018-02-19T10:51:09.000-08:00", "ratings_all_count"=>6015, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-02-22T12:08:11.000-08:00", "stop_date"=>"2018-02-22T12:08:11.000-08:00", "ratings_all_count"=>6016, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-02-26T10:59:52.000-08:00", "stop_date"=>"2018-02-27T23:41:09.000-08:00", "ratings_all_count"=>6018, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-03-01T11:21:19.000-08:00", "stop_date"=>"2018-03-01T11:21:19.000-08:00", "ratings_all_count"=>6019, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-03-15T18:10:58.000-07:00", "stop_date"=>"2018-03-15T18:10:58.000-07:00", "ratings_all_count"=>6025, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-03-05T11:32:02.000-08:00", "stop_date"=>"2018-03-19T20:14:16.000-07:00", "ratings_all_count"=>6024, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-03-26T06:26:58.000-07:00", "stop_date"=>"2018-03-26T06:26:58.000-07:00", "ratings_all_count"=>6027, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-04-02T12:56:03.000-07:00", "stop_date"=>"2018-04-02T12:56:03.000-07:00", "ratings_all_count"=>6029, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-04-09T13:15:06.000-07:00", "stop_date"=>"2018-04-09T13:15:06.000-07:00", "ratings_all_count"=>6032, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-04-05T13:11:01.000-07:00", "stop_date"=>"2018-04-12T14:48:48.000-07:00", "ratings_all_count"=>6033, "ratings_all_stars"=>3.44}, {"start_date"=>"2018-04-13T06:15:02.000-07:00", "stop_date"=>"2018-04-13T06:15:02.000-07:00", "ratings_all_count"=>6033, "ratings_all_stars"=>nil}, {"start_date"=>"2018-04-21T16:35:29.000-07:00", "stop_date"=>"2018-05-08T03:52:09.000-07:00", "ratings_all_count"=>6033, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-05-11T03:02:23.000-07:00", "stop_date"=>"2018-05-11T03:02:23.000-07:00", "ratings_all_count"=>6041, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-05-15T00:17:31.000-07:00", "stop_date"=>"2018-05-15T00:17:31.000-07:00", "ratings_all_count"=>6042, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-05-18T08:35:19.000-07:00", "stop_date"=>"2018-05-18T08:35:19.000-07:00", "ratings_all_count"=>6043, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-05-22T07:18:10.000-07:00", "stop_date"=>"2018-05-22T07:18:10.000-07:00", "ratings_all_count"=>6045, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-05-29T05:39:30.000-07:00", "stop_date"=>"2018-05-29T05:39:30.000-07:00", "ratings_all_count"=>6046, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-06-01T02:54:52.000-07:00", "stop_date"=>"2018-06-01T02:54:52.000-07:00", "ratings_all_count"=>6047, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-06-05T01:48:56.000-07:00", "stop_date"=>"2018-06-05T01:48:56.000-07:00", "ratings_all_count"=>6049, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-06-12T01:45:36.000-07:00", "stop_date"=>"2018-06-12T01:45:36.000-07:00", "ratings_all_count"=>6053, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-06-19T03:18:49.000-07:00", "stop_date"=>"2018-06-22T07:42:01.000-07:00", "ratings_all_count"=>6055, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-06-15T01:17:38.000-07:00", "stop_date"=>"2018-06-26T08:49:52.000-07:00", "ratings_all_count"=>6054, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-07-03T04:46:59.000-07:00", "stop_date"=>"2018-07-03T04:46:59.000-07:00", "ratings_all_count"=>6056, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-07-10T02:36:05.000-07:00", "stop_date"=>"2018-07-10T02:36:05.000-07:00", "ratings_all_count"=>6058, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-07-13T06:39:56.000-07:00", "stop_date"=>"2018-07-13T06:39:56.000-07:00", "ratings_all_count"=>6065, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-07-17T03:33:43.000-07:00", "stop_date"=>"2018-07-17T03:33:43.000-07:00", "ratings_all_count"=>6072, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-07-24T00:06:10.000-07:00", "stop_date"=>"2018-07-24T00:06:10.000-07:00", "ratings_all_count"=>6080, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-07-27T03:29:56.000-07:00", "stop_date"=>"2018-07-27T03:29:56.000-07:00", "ratings_all_count"=>6081, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-07-31T02:28:29.000-07:00", "stop_date"=>"2018-07-31T02:28:29.000-07:00", "ratings_all_count"=>6082, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-08-07T03:15:19.000-07:00", "stop_date"=>"2018-08-10T03:02:35.000-07:00", "ratings_all_count"=>6084, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-08-13T23:22:45.000-07:00", "stop_date"=>"2018-08-20T21:13:34.000-07:00", "ratings_all_count"=>6085, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-08-27T21:34:23.000-07:00", "stop_date"=>"2018-08-27T21:34:23.000-07:00", "ratings_all_count"=>6088, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-09-03T14:59:19.000-07:00", "stop_date"=>"2018-09-03T14:59:19.000-07:00", "ratings_all_count"=>6089, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-09-07T01:37:48.000-07:00", "stop_date"=>"2018-09-07T01:37:48.000-07:00", "ratings_all_count"=>6093, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-09-10T23:21:50.000-07:00", "stop_date"=>"2018-09-10T23:21:50.000-07:00", "ratings_all_count"=>6095, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-09-20T23:28:06.000-07:00", "stop_date"=>"2018-10-01T23:56:36.000-07:00", "ratings_all_count"=>6096, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-09-14T00:41:59.000-07:00", "stop_date"=>"2018-10-05T03:14:21.000-07:00", "ratings_all_count"=>6097, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-10-08T17:00:57.000-07:00", "stop_date"=>"2018-10-11T17:31:22.000-07:00", "ratings_all_count"=>6098, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-10-15T17:56:04.000-07:00", "stop_date"=>"2018-10-15T17:56:04.000-07:00", "ratings_all_count"=>6099, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-10-22T05:38:11.000-07:00", "stop_date"=>"2018-10-22T05:38:11.000-07:00", "ratings_all_count"=>6101, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-10-23T17:44:01.000-07:00", "stop_date"=>"2018-10-23T17:44:01.000-07:00", "ratings_all_count"=>6102, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-10-29T18:39:45.000-07:00", "stop_date"=>"2018-10-30T11:25:59.000-07:00", "ratings_all_count"=>6104, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-11-02T02:43:42.000-07:00", "stop_date"=>"2018-11-06T02:34:03.000-08:00", "ratings_all_count"=>6105, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-11-09T10:57:03.000-08:00", "stop_date"=>"2018-11-09T10:57:03.000-08:00", "ratings_all_count"=>6106, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-11-13T03:01:02.000-08:00", "stop_date"=>"2018-11-14T01:35:36.000-08:00", "ratings_all_count"=>6108, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-11-16T08:40:37.000-08:00", "stop_date"=>"2018-11-16T08:40:37.000-08:00", "ratings_all_count"=>6110, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-11-20T04:34:33.000-08:00", "stop_date"=>"2018-11-21T03:08:30.000-08:00", "ratings_all_count"=>6111, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-11-23T02:38:09.000-08:00", "stop_date"=>"2018-11-23T02:38:09.000-08:00", "ratings_all_count"=>6113, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-11-27T04:39:15.000-08:00", "stop_date"=>"2018-11-27T04:39:15.000-08:00", "ratings_all_count"=>6118, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-12-11T02:09:56.000-08:00", "stop_date"=>"2018-12-11T02:09:56.000-08:00", "ratings_all_count"=>6125, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-12-14T01:49:43.000-08:00", "stop_date"=>"2018-12-14T01:49:43.000-08:00", "ratings_all_count"=>6124, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-12-19T05:37:31.000-08:00", "stop_date"=>"2018-12-20T20:59:22.000-08:00", "ratings_all_count"=>6129, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-12-22T03:35:36.000-08:00", "stop_date"=>"2018-12-24T22:58:47.000-08:00", "ratings_all_count"=>6130, "ratings_all_stars"=>3.4}, {"start_date"=>"2018-12-25T16:59:37.000-08:00", "stop_date"=>"2018-12-28T00:08:27.000-08:00", "ratings_all_count"=>6131, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-01-01T03:02:30.000-08:00", "stop_date"=>"2019-01-01T03:02:30.000-08:00", "ratings_all_count"=>6132, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-01-08T06:51:10.000-08:00", "stop_date"=>"2019-01-08T06:51:10.000-08:00", "ratings_all_count"=>6134, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-01-10T14:03:52.000-08:00", "stop_date"=>"2019-01-11T14:13:06.000-08:00", "ratings_all_count"=>6135, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-01-15T02:54:30.000-08:00", "stop_date"=>"2019-01-15T02:54:30.000-08:00", "ratings_all_count"=>6136, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-01-18T15:37:07.000-08:00", "stop_date"=>"2019-01-18T15:37:07.000-08:00", "ratings_all_count"=>6137, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-01-24T15:29:50.000-08:00", "stop_date"=>"2019-01-24T15:29:50.000-08:00", "ratings_all_count"=>6141, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-01-29T07:47:14.000-08:00", "stop_date"=>"2019-01-29T07:47:14.000-08:00", "ratings_all_count"=>6142, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-02-04T14:18:17.000-08:00", "stop_date"=>"2019-02-14T14:10:55.000-08:00", "ratings_all_count"=>6143, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-02-07T15:06:55.000-08:00", "stop_date"=>"2019-02-19T08:30:49.000-08:00", "ratings_all_count"=>6144, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-02-23T03:18:10.000-08:00", "stop_date"=>"2019-02-23T03:18:10.000-08:00", "ratings_all_count"=>6145, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-02-25T18:56:03.000-08:00", "stop_date"=>"2019-02-28T18:24:20.000-08:00", "ratings_all_count"=>6146, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-03-04T18:39:16.000-08:00", "stop_date"=>"2019-03-04T18:39:16.000-08:00", "ratings_all_count"=>6147, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-03-07T19:57:11.000-08:00", "stop_date"=>"2019-03-07T19:57:11.000-08:00", "ratings_all_count"=>6149, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-03-11T22:29:08.000-07:00", "stop_date"=>"2019-03-11T22:29:08.000-07:00", "ratings_all_count"=>6148, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-03-14T23:34:36.000-07:00", "stop_date"=>"2019-03-14T23:34:36.000-07:00", "ratings_all_count"=>6150, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-03-18T16:14:28.000-07:00", "stop_date"=>"2019-04-01T18:30:50.000-07:00", "ratings_all_count"=>6153, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-03-25T16:31:05.000-07:00", "stop_date"=>"2019-04-12T01:35:33.000-07:00", "ratings_all_count"=>6154, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-04-15T15:58:26.000-07:00", "stop_date"=>"2019-04-18T16:13:35.000-07:00", "ratings_all_count"=>6156, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-07-02T07:51:27.000-07:00", "stop_date"=>"2019-07-04T23:37:27.000-07:00", "ratings_all_count"=>6169, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-07-08T22:07:36.000-07:00", "stop_date"=>"2019-07-11T23:49:38.000-07:00", "ratings_all_count"=>6171, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-07-16T12:23:19.000-07:00", "stop_date"=>"2019-07-16T12:23:19.000-07:00", "ratings_all_count"=>6173, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-07-18T21:52:33.000-07:00", "stop_date"=>"2019-07-18T21:52:33.000-07:00", "ratings_all_count"=>6175, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-07-22T23:09:13.000-07:00", "stop_date"=>"2019-07-22T23:09:13.000-07:00", "ratings_all_count"=>6176, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-07-25T23:31:20.000-07:00", "stop_date"=>"2019-07-25T23:31:20.000-07:00", "ratings_all_count"=>6177, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-07-29T22:41:28.000-07:00", "stop_date"=>"2019-08-01T21:58:33.000-07:00", "ratings_all_count"=>6179, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-08-07T07:14:32.000-07:00", "stop_date"=>"2019-08-07T07:14:32.000-07:00", "ratings_all_count"=>6109, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-08-08T18:26:30.000-07:00", "stop_date"=>"2019-08-08T18:26:30.000-07:00", "ratings_all_count"=>6178, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-08-15T22:28:13.000-07:00", "stop_date"=>"2019-08-15T22:28:13.000-07:00", "ratings_all_count"=>6165, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-08-22T02:30:12.000-07:00", "stop_date"=>"2019-08-22T02:30:12.000-07:00", "ratings_all_count"=>5796, "ratings_all_stars"=>3.4}, {"start_date"=>"2019-08-19T21:24:21.000-07:00", "stop_date"=>"2019-08-24T20:45:29.000-07:00", "ratings_all_count"=>6182, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-08-27T21:15:01.000-07:00", "stop_date"=>"2019-08-27T21:15:01.000-07:00", "ratings_all_count"=>6183, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-01T01:32:52.000-07:00", "stop_date"=>"2019-09-01T01:32:52.000-07:00", "ratings_all_count"=>6180, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-05T00:18:37.000-07:00", "stop_date"=>"2019-09-05T00:18:37.000-07:00", "ratings_all_count"=>6144, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-14T19:17:20.000-07:00", "stop_date"=>"2019-09-14T19:17:20.000-07:00", "ratings_all_count"=>6157, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-23T10:58:00.000-07:00", "stop_date"=>"2019-09-23T10:58:00.000-07:00", "ratings_all_count"=>6035, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-14T07:48:14.000-07:00", "stop_date"=>"2019-09-24T10:09:50.000-07:00", "ratings_all_count"=>6187, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-30T18:38:42.000-07:00", "stop_date"=>"2019-09-30T18:38:42.000-07:00", "ratings_all_count"=>6176, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-03T18:39:47.000-07:00", "stop_date"=>"2019-10-03T18:39:47.000-07:00", "ratings_all_count"=>6149, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-10T21:39:22.000-07:00", "stop_date"=>"2019-10-08T02:38:47.000-07:00", "ratings_all_count"=>6161, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-10T16:47:21.000-07:00", "stop_date"=>"2019-10-10T16:47:21.000-07:00", "ratings_all_count"=>6191, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-15T03:51:38.000-07:00", "stop_date"=>"2019-10-17T22:08:17.000-07:00", "ratings_all_count"=>6146, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-24T19:06:50.000-07:00", "stop_date"=>"2019-10-25T16:57:36.000-07:00", "ratings_all_count"=>6196, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-26T15:46:12.000-07:00", "stop_date"=>"2019-10-26T15:46:12.000-07:00", "ratings_all_count"=>6197, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-27T00:57:47.000-07:00", "stop_date"=>"2019-10-27T00:57:47.000-07:00", "ratings_all_count"=>5374, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-29T00:05:55.000-07:00", "stop_date"=>"2019-10-29T00:05:55.000-07:00", "ratings_all_count"=>6068, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-29T13:02:31.000-07:00", "stop_date"=>"2019-10-29T13:02:31.000-07:00", "ratings_all_count"=>6170, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-09-06T03:48:12.000-07:00", "stop_date"=>"2019-10-30T06:20:38.000-07:00", "ratings_all_count"=>6172, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-10-31T19:00:26.000-07:00", "stop_date"=>"2019-11-01T12:58:36.000-07:00", "ratings_all_count"=>6185, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-11-05T02:26:32.000-08:00", "stop_date"=>"2019-11-05T02:26:32.000-08:00", "ratings_all_count"=>6021, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-11-07T20:51:37.000-08:00", "stop_date"=>"2019-11-07T20:51:37.000-08:00", "ratings_all_count"=>6135, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-11-12T06:33:58.000-08:00", "stop_date"=>"2019-11-12T06:33:58.000-08:00", "ratings_all_count"=>5969, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-11-16T00:56:45.000-08:00", "stop_date"=>"2019-11-28T01:44:37.000-08:00", "ratings_all_count"=>6201, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-11-28T20:24:21.000-08:00", "stop_date"=>"2019-11-28T20:24:21.000-08:00", "ratings_all_count"=>6202, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-12-04T00:27:12.000-08:00", "stop_date"=>"2019-12-06T06:38:46.000-08:00", "ratings_all_count"=>6205, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-12-09T20:40:28.000-08:00", "stop_date"=>"2019-12-13T06:15:34.000-08:00", "ratings_all_count"=>6206, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-12-17T05:38:58.000-08:00", "stop_date"=>"2019-12-17T05:38:58.000-08:00", "ratings_all_count"=>6207, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-12-19T19:14:23.000-08:00", "stop_date"=>"2019-12-19T19:14:23.000-08:00", "ratings_all_count"=>6209, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-12-25T08:58:16.000-08:00", "stop_date"=>"2020-01-02T14:47:58.000-08:00", "ratings_all_count"=>6211, "ratings_all_stars"=>3.3}, {"start_date"=>"2019-12-30T23:05:31.000-08:00", "stop_date"=>"2020-01-06T15:46:58.000-08:00", "ratings_all_count"=>6212, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-01-13T15:04:24.000-08:00", "stop_date"=>"2020-01-13T15:04:24.000-08:00", "ratings_all_count"=>6216, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-01-16T15:13:55.000-08:00", "stop_date"=>"2020-01-21T06:43:44.000-08:00", "ratings_all_count"=>6218, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-01-23T21:55:31.000-08:00", "stop_date"=>"2020-02-10T17:26:06.000-08:00", "ratings_all_count"=>6219, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-02-18T02:08:51.000-08:00", "stop_date"=>"2020-02-18T02:08:51.000-08:00", "ratings_all_count"=>6220, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-02-28T02:43:45.000-08:00", "stop_date"=>"2020-03-02T21:21:10.000-08:00", "ratings_all_count"=>6221, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-02-22T03:27:02.000-08:00", "stop_date"=>"2020-03-10T19:34:06.000-07:00", "ratings_all_count"=>6222, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-03-16T19:24:21.000-07:00", "stop_date"=>"2020-03-16T19:24:21.000-07:00", "ratings_all_count"=>6224, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-03-21T09:51:46.000-07:00", "stop_date"=>"2020-03-21T09:51:46.000-07:00", "ratings_all_count"=>6225, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-03-24T07:24:35.000-07:00", "stop_date"=>"2020-03-25T09:59:33.000-07:00", "ratings_all_count"=>6227, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-03-27T23:07:55.000-07:00", "stop_date"=>"2020-03-30T09:30:18.000-07:00", "ratings_all_count"=>6230, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-04-02T06:40:59.000-07:00", "stop_date"=>"2020-04-02T06:40:59.000-07:00", "ratings_all_count"=>6231, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-04-06T06:39:30.000-07:00", "stop_date"=>"2020-04-06T06:39:30.000-07:00", "ratings_all_count"=>6232, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-04-09T06:46:11.000-07:00", "stop_date"=>"2020-04-13T06:45:42.000-07:00", "ratings_all_count"=>6234, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-04-16T06:36:09.000-07:00", "stop_date"=>"2020-04-16T06:36:09.000-07:00", "ratings_all_count"=>6235, "ratings_all_stars"=>3.3}, {"start_date"=>"2020-04-20T06:44:41.000-07:00", "stop_date"=>nil, "ratings_all_count"=>6239, "ratings_all_stars"=>3.3}], "content_rating"=>"Everyone", "last_updated"=>"2019-11-10", "current_version"=>"5.1.3", "platform"=>"android", "downloads_history"=>[{"start_date"=>"2016-09-20T12:54:23.000-07:00", "stop_date"=>nil, "downloads_min"=>1000000, "downloads_max"=>5000000}], "developer_google_play_identifier"=>"zenofx.com", "sdk_activity"=>[{"id"=>55639, "name"=>"AWS In-App Purchasing", "last_seen_date"=>"2019-11-16T04:25:20.000-08:00", "first_seen_date"=>"2019-10-18T05:06:34.000-07:00", "activities"=>[{"type"=>"install", "date"=>"2019-10-18T05:06:34.000-07:00"}], "categories"=>["Payments"], "installed"=>true}], "has_fb_ad_spend"=>false, "headquarters"=>[{"domain"=>"zenofx.com", "street_number"=>nil, "street_name"=>nil, "sub_premise"=>nil, "city"=>nil, "postal_code"=>nil, "state"=>nil, "state_code"=>nil, "country"=>nil, "country_code"=>nil, "lat"=>nil, "lng"=>nil}], "downloads_min"=>1000000, "in_app_purchase_min"=>399, "last_scanned_date"=>"2019-11-16T12:25:20Z"}
    @json_publisher = {"websites"=>[], "id"=>48653, "name"=>"zhiping hou", "publisher_identifier"=>929448160, "platform"=>"ios", "apps"=>[{"id"=>110332, "platform"=>"ios"}, {"id"=>1083028, "platform"=>"ios"}, {"id"=>1203250, "platform"=>"ios"}, {"id"=>1220856, "platform"=>"ios"}, {"id"=>1247828, "platform"=>"ios"}, {"id"=>1248918, "platform"=>"ios"}, {"id"=>1250639, "platform"=>"ios"}, {"id"=>1252341, "platform"=>"ios"}, {"id"=>1258304, "platform"=>"ios"}, {"id"=>1262934, "platform"=>"ios"}, {"id"=>1273100, "platform"=>"ios"}, {"id"=>1275090, "platform"=>"ios"}, {"id"=>1277485, "platform"=>"ios"}, {"id"=>1280978, "platform"=>"ios"}, {"id"=>1311933, "platform"=>"ios"}, {"id"=>1317439, "platform"=>"ios"}, {"id"=>1322704, "platform"=>"ios"}, {"id"=>1326397, "platform"=>"ios"}, {"id"=>1332857, "platform"=>"ios"}, {"id"=>1333696, "platform"=>"ios"}, {"id"=>1334937, "platform"=>"ios"}, {"id"=>1337803, "platform"=>"ios"}, {"id"=>1338389, "platform"=>"ios"}, {"id"=>1352286, "platform"=>"ios"}, {"id"=>1354346, "platform"=>"ios"}, {"id"=>1358236, "platform"=>"ios"}, {"id"=>1358536, "platform"=>"ios"}, {"id"=>1362083, "platform"=>"ios"}, {"id"=>1362790, "platform"=>"ios"}, {"id"=>1365487, "platform"=>"ios"}, {"id"=>1367400, "platform"=>"ios"}, {"id"=>1368601, "platform"=>"ios"}, {"id"=>1375068, "platform"=>"ios"}, {"id"=>1377502, "platform"=>"ios"}, {"id"=>1401738, "platform"=>"ios"}, {"id"=>1403083, "platform"=>"ios"}, {"id"=>1414406, "platform"=>"ios"}, {"id"=>1421939, "platform"=>"ios"}, {"id"=>1431380, "platform"=>"ios"}, {"id"=>1440545, "platform"=>"ios"}, {"id"=>1444614, "platform"=>"ios"}, {"id"=>1446111, "platform"=>"ios"}, {"id"=>1447438, "platform"=>"ios"}, {"id"=>1454951, "platform"=>"ios"}, {"id"=>1456717, "platform"=>"ios"}, {"id"=>1457369, "platform"=>"ios"}, {"id"=>1463855, "platform"=>"ios"}, {"id"=>1467839, "platform"=>"ios"}, {"id"=>1470203, "platform"=>"ios"}, {"id"=>1472102, "platform"=>"ios"}, {"id"=>1474590, "platform"=>"ios"}, {"id"=>1480652, "platform"=>"ios"}, {"id"=>1482489, "platform"=>"ios"}, {"id"=>1482851, "platform"=>"ios"}, {"id"=>1487278, "platform"=>"ios"}, {"id"=>1489712, "platform"=>"ios"}, {"id"=>1492588, "platform"=>"ios"}, {"id"=>1493382, "platform"=>"ios"}, {"id"=>1493522, "platform"=>"ios"}, {"id"=>1493600, "platform"=>"ios"}, {"id"=>1495898, "platform"=>"ios"}, {"id"=>1502811, "platform"=>"ios"}, {"id"=>1505791, "platform"=>"ios"}, {"id"=>1506351, "platform"=>"ios"}, {"id"=>1506473, "platform"=>"ios"}, {"id"=>1507282, "platform"=>"ios"}, {"id"=>1512991, "platform"=>"ios"}, {"id"=>1513301, "platform"=>"ios"}, {"id"=>1517087, "platform"=>"ios"}, {"id"=>1517268, "platform"=>"ios"}, {"id"=>1523528, "platform"=>"ios"}, {"id"=>1528036, "platform"=>"ios"}, {"id"=>1530945, "platform"=>"ios"}, {"id"=>1541358, "platform"=>"ios"}, {"id"=>1543109, "platform"=>"ios"}, {"id"=>1548789, "platform"=>"ios"}, {"id"=>1566262, "platform"=>"ios"}, {"id"=>1583480, "platform"=>"ios"}, {"id"=>1595061, "platform"=>"ios"}, {"id"=>1605587, "platform"=>"ios"}, {"id"=>1606272, "platform"=>"ios"}, {"id"=>1608547, "platform"=>"ios"}, {"id"=>1611044, "platform"=>"ios"}, {"id"=>1611317, "platform"=>"ios"}, {"id"=>1619893, "platform"=>"ios"}, {"id"=>1620494, "platform"=>"ios"}, {"id"=>1634946, "platform"=>"ios"}, {"id"=>1638856, "platform"=>"ios"}, {"id"=>1652340, "platform"=>"ios"}, {"id"=>1657985, "platform"=>"ios"}, {"id"=>1663000, "platform"=>"ios"}, {"id"=>1665865, "platform"=>"ios"}, {"id"=>1668944, "platform"=>"ios"}, {"id"=>1711805, "platform"=>"ios"}, {"id"=>1717236, "platform"=>"ios"}, {"id"=>1737015, "platform"=>"ios"}, {"id"=>1772490, "platform"=>"ios"}, {"id"=>1781988, "platform"=>"ios"}, {"id"=>1793088, "platform"=>"ios"}, {"id"=>1795471, "platform"=>"ios"}, {"id"=>1801829, "platform"=>"ios"}, {"id"=>1816420, "platform"=>"ios"}, {"id"=>1823846, "platform"=>"ios"}, {"id"=>1846183, "platform"=>"ios"}, {"id"=>1870306, "platform"=>"ios"}, {"id"=>1902730, "platform"=>"ios"}, {"id"=>1922063, "platform"=>"ios"}, {"id"=>1931886, "platform"=>"ios"}, {"id"=>1938516, "platform"=>"ios"}, {"id"=>1945093, "platform"=>"ios"}, {"id"=>1952674, "platform"=>"ios"}, {"id"=>1993825, "platform"=>"ios"}, {"id"=>2014325, "platform"=>"ios"}, {"id"=>2060009, "platform"=>"ios"}, {"id"=>2061255, "platform"=>"ios"}, {"id"=>2067182, "platform"=>"ios"}, {"id"=>2068808, "platform"=>"ios"}, {"id"=>2069542, "platform"=>"ios"}, {"id"=>2070071, "platform"=>"ios"}, {"id"=>2099615, "platform"=>"ios"}, {"id"=>2121226, "platform"=>"ios"}, {"id"=>2123078, "platform"=>"ios"}, {"id"=>2123434, "platform"=>"ios"}, {"id"=>2125894, "platform"=>"ios"}, {"id"=>2159034, "platform"=>"ios"}, {"id"=>2159811, "platform"=>"ios"}, {"id"=>2168760, "platform"=>"ios"}, {"id"=>2169064, "platform"=>"ios"}, {"id"=>2170068, "platform"=>"ios"}, {"id"=>2170802, "platform"=>"ios"}, {"id"=>2171595, "platform"=>"ios"}, {"id"=>2172563, "platform"=>"ios"}, {"id"=>2173654, "platform"=>"ios"}, {"id"=>2178217, "platform"=>"ios"}, {"id"=>2178255, "platform"=>"ios"}, {"id"=>2179607, "platform"=>"ios"}, {"id"=>2196182, "platform"=>"ios"}, {"id"=>2196967, "platform"=>"ios"}, {"id"=>2228862, "platform"=>"ios"}, {"id"=>2251220, "platform"=>"ios"}, {"id"=>2257854, "platform"=>"ios"}, {"id"=>2261497, "platform"=>"ios"}, {"id"=>2261867, "platform"=>"ios"}, {"id"=>2268337, "platform"=>"ios"}, {"id"=>2270436, "platform"=>"ios"}, {"id"=>2273185, "platform"=>"ios"}, {"id"=>2273464, "platform"=>"ios"}, {"id"=>2274544, "platform"=>"ios"}, {"id"=>2287173, "platform"=>"ios"}, {"id"=>2289077, "platform"=>"ios"}, {"id"=>2320341, "platform"=>"ios"}, {"id"=>2334596, "platform"=>"ios"}, {"id"=>2343449, "platform"=>"ios"}, {"id"=>2345076, "platform"=>"ios"}, {"id"=>2350348, "platform"=>"ios"}, {"id"=>2353010, "platform"=>"ios"}, {"id"=>2355810, "platform"=>"ios"}, {"id"=>2358156, "platform"=>"ios"}, {"id"=>2363928, "platform"=>"ios"}, {"id"=>2373500, "platform"=>"ios"}, {"id"=>2376410, "platform"=>"ios"}, {"id"=>2376576, "platform"=>"ios"}, {"id"=>2376617, "platform"=>"ios"}, {"id"=>2382988, "platform"=>"ios"}, {"id"=>2384529, "platform"=>"ios"}, {"id"=>2387755, "platform"=>"ios"}, {"id"=>2390939, "platform"=>"ios"}, {"id"=>2391762, "platform"=>"ios"}, {"id"=>2408012, "platform"=>"ios"}, {"id"=>2424143, "platform"=>"ios"}, {"id"=>2428024, "platform"=>"ios"}, {"id"=>2588459, "platform"=>"ios"}, {"id"=>2588467, "platform"=>"ios"}, {"id"=>2592357, "platform"=>"ios"}, {"id"=>2596482, "platform"=>"ios"}, {"id"=>2598206, "platform"=>"ios"}, {"id"=>2602668, "platform"=>"ios"}, {"id"=>2604275, "platform"=>"ios"}, {"id"=>2634964, "platform"=>"ios"}, {"id"=>2636796, "platform"=>"ios"}, {"id"=>2641864, "platform"=>"ios"}, {"id"=>2641866, "platform"=>"ios"}, {"id"=>2641997, "platform"=>"ios"}, {"id"=>2645518, "platform"=>"ios"}, {"id"=>2646960, "platform"=>"ios"}, {"id"=>2647099, "platform"=>"ios"}, {"id"=>2649534, "platform"=>"ios"}, {"id"=>2650744, "platform"=>"ios"}, {"id"=>2654708, "platform"=>"ios"}, {"id"=>2656139, "platform"=>"ios"}, {"id"=>2656140, "platform"=>"ios"}, {"id"=>2662103, "platform"=>"ios"}, {"id"=>2663292, "platform"=>"ios"}, {"id"=>2665544, "platform"=>"ios"}, {"id"=>2665550, "platform"=>"ios"}, {"id"=>2665844, "platform"=>"ios"}, {"id"=>2691453, "platform"=>"ios"}, {"id"=>2691456, "platform"=>"ios"}, {"id"=>2691457, "platform"=>"ios"}, {"id"=>2691458, "platform"=>"ios"}, {"id"=>2691592, "platform"=>"ios"}, {"id"=>2691593, "platform"=>"ios"}, {"id"=>2693727, "platform"=>"ios"}, {"id"=>2702838, "platform"=>"ios"}, {"id"=>2705845, "platform"=>"ios"}, {"id"=>2709833, "platform"=>"ios"}, {"id"=>2722134, "platform"=>"ios"}, {"id"=>2722135, "platform"=>"ios"}, {"id"=>2733956, "platform"=>"ios"}, {"id"=>2734963, "platform"=>"ios"}, {"id"=>2737735, "platform"=>"ios"}, {"id"=>2740031, "platform"=>"ios"}, {"id"=>2740387, "platform"=>"ios"}, {"id"=>2742872, "platform"=>"ios"}, {"id"=>2745440, "platform"=>"ios"}, {"id"=>2747440, "platform"=>"ios"}, {"id"=>2777451, "platform"=>"ios"}, {"id"=>2777452, "platform"=>"ios"}, {"id"=>2788884, "platform"=>"ios"}, {"id"=>2789233, "platform"=>"ios"}, {"id"=>2792935, "platform"=>"ios"}, {"id"=>2871168, "platform"=>"ios"}, {"id"=>2876034, "platform"=>"ios"}, {"id"=>2883114, "platform"=>"ios"}, {"id"=>2929771, "platform"=>"ios"}, {"id"=>2929772, "platform"=>"ios"}, {"id"=>2931851, "platform"=>"ios"}, {"id"=>2931853, "platform"=>"ios"}, {"id"=>2931854, "platform"=>"ios"}, {"id"=>2932726, "platform"=>"ios"}, {"id"=>2932727, "platform"=>"ios"}, {"id"=>2932728, "platform"=>"ios"}, {"id"=>2932875, "platform"=>"ios"}, {"id"=>2936681, "platform"=>"ios"}, {"id"=>2937304, "platform"=>"ios"}, {"id"=>2937306, "platform"=>"ios"}, {"id"=>2946043, "platform"=>"ios"}, {"id"=>2955282, "platform"=>"ios"}, {"id"=>2960332, "platform"=>"ios"}, {"id"=>2969341, "platform"=>"ios"}, {"id"=>2981327, "platform"=>"ios"}, {"id"=>2984290, "platform"=>"ios"}, {"id"=>2984294, "platform"=>"ios"}, {"id"=>3029826, "platform"=>"ios"}, {"id"=>3034829, "platform"=>"ios"}, {"id"=>3035397, "platform"=>"ios"}, {"id"=>3038043, "platform"=>"ios"}, {"id"=>3040366, "platform"=>"ios"}, {"id"=>3040654, "platform"=>"ios"}, {"id"=>3048537, "platform"=>"ios"}, {"id"=>3049581, "platform"=>"ios"}, {"id"=>3058416, "platform"=>"ios"}, {"id"=>3058611, "platform"=>"ios"}, {"id"=>3060121, "platform"=>"ios"}, {"id"=>3062303, "platform"=>"ios"}, {"id"=>3062757, "platform"=>"ios"}, {"id"=>3063489, "platform"=>"ios"}, {"id"=>3065354, "platform"=>"ios"}, {"id"=>3065355, "platform"=>"ios"}, {"id"=>3066509, "platform"=>"ios"}, {"id"=>3067970, "platform"=>"ios"}, {"id"=>3071092, "platform"=>"ios"}, {"id"=>3075720, "platform"=>"ios"}, {"id"=>3077368, "platform"=>"ios"}, {"id"=>3079061, "platform"=>"ios"}, {"id"=>3083724, "platform"=>"ios"}, {"id"=>3084228, "platform"=>"ios"}, {"id"=>3084229, "platform"=>"ios"}, {"id"=>3085234, "platform"=>"ios"}, {"id"=>3085251, "platform"=>"ios"}, {"id"=>3086930, "platform"=>"ios"}, {"id"=>3087388, "platform"=>"ios"}, {"id"=>3088377, "platform"=>"ios"}, {"id"=>3088405, "platform"=>"ios"}, {"id"=>3088413, "platform"=>"ios"}, {"id"=>3109881, "platform"=>"ios"}, {"id"=>3148872, "platform"=>"ios"}, {"id"=>3156350, "platform"=>"ios"}, {"id"=>3163863, "platform"=>"ios"}], "contacts"=>0}
    if @app.present? && !@app.taken_down? && @json_app.present?
      @top_apps = @json_publisher.present? ? select_top_apps_from(@json_publisher['apps'], 5) : []
      @last_update_date = latest_release_of(@app).to_date
      @latest_update = (Date.current - @last_update_date).to_i
      @sdks = @json_app['sdk_activity']
      @sdk_installed = @sdks.count {|sdk| sdk['installed']}
      @sdk_uninstalled = @sdks.count {|sdk| !sdk['installed']}
      @installed_sdk_categories = @sdks.reduce({}) do |memo, sdk|
        next memo unless sdk['installed'] && sdk['categories']
        sdk['categories'].each {|cat| memo[cat] ? memo[cat] += 1 : memo[cat] = 1}
        memo
      end
      @uninstalled_sdk_categories = @sdks.reduce({}) do |memo, sdk|
        next memo unless !sdk['installed'] && sdk['categories']
        sdk['categories'].each {|cat| memo[cat] ? memo[cat] += 1 : memo[cat] = 1}
        memo
      end
      @categories = @json_app['categories'].andand.map {|cat| cat['name']}
    else
      redirect_to root_path, notice: "Sorry, we couldn't find that app."
    end
  end
  
  def sdk_page
    @platform = params[:platform] == 'ios' ? 'ios' : 'android'
    @sdk = get_sdk(@platform, params[:sdk_id])
    @json_sdk = sdks_hot_store.read(@platform, @sdk.id)
    @json_sdk['summary'] = @json_sdk['summary'].blank? ? "" : @json_sdk['summary']
    @installs_over_time = get_last(5, @json_sdk['installs_over_time'])
    @uninstalls_over_time = get_last(5, @json_sdk['uninstalls_over_time'])
    @apps_over_time = get_last(5, @json_sdk['apps_over_time'])
    @market_share_over_time = get_last(5, @json_sdk['market_share_over_time'])
    @categories = @json_sdk['categories'].andand.map {|cat| cat['name']}
    similars = @json_sdk['similar_sdks'] || '{}'
    @similar_sdks = JSON.parse(similars)
    competitives = @json_sdk['competitive_sdks'] || '{}'
    @competitive_sdks = JSON.parse(competitives)
    @top_8_apps = @sdk.top_200_apps.first(8).map{|app| simplify_json_app(apps_hot_store.read(@platform, app.id))}
    @apps_installed_now = @apps_over_time.to_h.values.first.to_i rescue 0
    @apps_start = @apps_over_time.to_h.keys.last rescue 'a few months ago'
    @apps_installed_start = @apps_over_time.to_h.values.last.to_i rescue 0
    @sdks_installed_now = @installs_over_time.to_h.values.first.to_i rescue 0
    @sdks_uninstalled_now = @uninstalls_over_time.to_h.values.first.to_i rescue 0
    @market_share_now = (@market_share_over_time.to_h.values.first.to_f) rescue 0
    @market_share_start = (@market_share_over_time.to_h.values.last.to_f) rescue 0
    @market_share_start_month = @market_share_over_time.to_h.keys.last rescue 'a few months ago'
    @market_share_now_month = @market_share_over_time.to_h.keys.first rescue 'this month'
  end
  
  def sdk_directory
    @platform = params[:platform] || 'ios'
    @letter = params[:letter] || 'a'
    @page = params[:page] || 1
    if @platform == 'ios'
      @sdks = IosSdk.where(deprecated: false).where("name like ?", "#{@letter.to_s}%")
    else 
      @sdks = AndroidSdk.where(flagged: false).where("name like ?", "#{@letter.to_s}%")
    end
  end
  
  def sdk_category_page
    @category = Tag.find params[:category_id]
    @json_category = sdk_categories_hot_store.read(@category.name)
    @json_category['description'] = @json_category['description'].blank? ? "We do not yet have a description for this SDK category." : @json_category['description']
    @android_installs_over_time = get_last(5, @json_category['android_installs_over_time'])
    @android_uninstalls_over_time = get_last(5, @json_category['android_uninstalls_over_time'])
    @ios_installs_over_time = get_last(5, @json_category['ios_installs_over_time'])
    @ios_uninstalls_over_time = get_last(5, @json_category['ios_uninstalls_over_time'])
    @android_apps_over_time = get_last(5, @json_category['android_apps_over_time'])
    @ios_apps_over_time = get_last(5, @json_category['ios_apps_over_time'])
    @top_ios_sdks = get_top(5, IosSdk.joins(:tags).where('tags.id = ?', @category).map{|sdk| sdks_hot_store.read('ios', sdk.id)})
    @top_android_sdks = get_top(5, AndroidSdk.joins(:tags).where('tags.id = ?', @category).map{|sdk| sdks_hot_store.read('android', sdk.id)})
    @android_apps_installed_now = @android_apps_over_time.to_h.values.first.to_i rescue 0
    @android_apps_start = @android_apps_over_time.to_h.keys.last rescue 'this month'
    @android_apps_installed_start = @android_apps_over_time.to_h.values.last.to_i rescue 0
    @android_sdks_installed_now = @android_installs_over_time.to_h.values.first.to_i rescue 0
    @android_sdks_uninstalled_now = @android_uninstalls_over_time.to_h.values.first.to_i rescue 0
    @android_sdks_start = @android_installs_over_time.to_h.keys.last rescue 'this month'
    @android_sdks_installed_start = @android_installs_over_time.to_h.values.last.to_i rescue 0
    @ios_apps_installed_now = @ios_apps_over_time.to_h.values.first.to_i rescue 0
    @ios_apps_start = @ios_apps_over_time.to_h.keys.last rescue 'this month'
    @ios_apps_installed_start = @ios_apps_over_time.to_h.values.last.to_i rescue 0
    @ios_sdks_installed_now = @ios_installs_over_time.to_h.values.first.to_i rescue 0
    @ios_sdks_uninstalled_now = @ios_uninstalls_over_time.to_h.values.first.to_i rescue 0
    @ios_sdks_start = @ios_installs_over_time.to_h.keys.last rescue 'this month'
    @ios_sdks_installed_start = @ios_installs_over_time.to_h.values.last.to_i rescue 0
  end

  def sdk_category_directory
    blacklist = ["Major App", "Major Publisher"]
    @categories = Tag.where.not(name: blacklist).order(:name)
  end
  
  def sdk_category_directory_sdks
    @category = Tag.find params[:category_id]
    @ios_sdks = @category.ios_sdks
    @android_sdks = @category.android_sdks
  end  

  def android_app_sdks
    app_ids = AndroidAppRankingSnapshot.top_200_app_ids

    if app_ids.include?(params[:app_identifier].to_i)
      @app = AndroidApp.find(params[:app_identifier])
      @sdks = @app.tagged_sdk_response(true)
    end

    respond_to do |format|
      format.js
    end
  end

  def timeline
    top_200_ids = IosAppRankingSnapshot.top_200_app_ids
    batches_i = WeeklyBatch.where(activity_type: [WeeklyBatch.activity_types[:install], WeeklyBatch.activity_types[:entered_top_apps]],
                                  owner_id: top_200_ids, owner_type: 'IosApp', week: Time.now - 1.month..Time.now).order('week desc')
    top_200_ids_a = AndroidAppRankingSnapshot.top_200_app_ids
    batches_a = WeeklyBatch.where(activity_type: [WeeklyBatch.activity_types[:install], WeeklyBatch.activity_types[:entered_top_apps]],
                                  owner_id: top_200_ids_a, owner_type: 'AndroidApp', week: Time.now - 1.month..Time.now).order('week desc')

    batches_by_week = {}
    (batches_i + batches_a).each do |batch|
      if batches_by_week[batch.week]
        batches_by_week[batch.week] << batch
      else
        batches_by_week[batch.week] = [batch]
      end
    end

    batches_by_week.sort_by {|k, v| -(k.to_time.to_i)}
    @batches_by_week = batches_by_week
  end

  def top_ios_sdks
    @last_updated = IosAppRankingSnapshot.last_valid_snapshot.try(:created_at) || Time.now
    @tag_label = "All"
    @sdks = IosSdk.sdks_installed_in_top_n_apps(200)
    @tags = IosSdk.top_200_tags

    if params[:tag]
      @tag = Tag.find(params[:tag])
      @tag_label = @tag.name
      @sdks = @sdks.select {|sdk| sdk.tags.include? @tag}
    end

    @sdks = Kaminari.paginate_array(@sdks).page(params[:page]).per(20)
    public_next_prev_links(@sdks, top_ios_sdks_path, params[:tag])
  end

  def top_ios_apps
    newest_snapshot = IosAppRankingSnapshot.last_valid_snapshot
    @last_updated = newest_snapshot.try(:created_at) || Time.now
    @apps = if newest_snapshot
              IosApp.joins(:ios_app_rankings).where(ios_app_rankings: {ios_app_ranking_snapshot_id: newest_snapshot.id}).select(:rank, 'ios_apps.*').order('rank ASC')
            else
              []
            end
  end

  def top_android_sdks
    @last_updated = AndroidAppRankingSnapshot.last_valid_snapshot.try(:created_at) || Time.now
    @tag_label = "All"
    @sdks = AndroidSdk.sdks_installed_in_top_n_apps(200)
    @tags = AndroidSdk.top_200_tags

    if params[:tag]
      @tag = Tag.find(params[:tag])
      @tag_label = @tag.name
      @sdks = @sdks.select {|sdk| sdk.tags.include? @tag}
    end
    @sdks = Kaminari.paginate_array(@sdks).page(params[:page]).per(20)
    public_next_prev_links(@sdks, top_android_sdks_path, params[:tag])
  end

  def top_android_apps
    newest_snapshot = AndroidAppRankingSnapshot.last_valid_snapshot
    @last_updated = newest_snapshot.try(:created_at) || Time.now
    @apps = if newest_snapshot
              AndroidApp.joins(:android_app_rankings).where(android_app_rankings: {android_app_ranking_snapshot_id: newest_snapshot.id}).
                  select(:rank, 'android_apps.*').order('rank ASC').limit(200)
            else
              []
            end
  end

  def fastest_growing_sdks
    @blog_post = buttercms_post_path('fastest-growing-sdks-of-2017')
  end

  def data
    get_logos

    @dna_graphic = graphics_folder + 'dna.svg'
    @scope_graphic = graphics_folder + 'scope.svg'
    @live_graphic = graphics_folder + 'live.svg'
    @legos_graphic = graphics_folder + 'legos.svg'
  end

  def publisher_contacts
    get_logos

    @abm_graphic = graphics_folder + 'app_publisher_contact_info.jpg'
    @sfdc_graphic = graphics_folder + 'mightysignal_plus_salesforce.png'
    @contact_box = graphics_folder + 'contacts_box.png'
    @publishers_graphic = graphics_folder + 'publishers_results.jpg'
  end

  def web_portal
    get_logos

    @timeline_graphic = graphics_folder + 'timeline.gif'
    @explore_graphic = graphics_folder + 'explore.gif'
    @live_scan_graphic = graphics_folder + 'live_scan.gif'
    @popular_apps_graphic = graphics_folder + 'popular_apps.gif'
    @ad_intelligence_graphic = graphics_folder + 'ad_intel.gif'
  end

  def the_api
    get_logos

    @api_graphic = graphics_folder + 'api.png'
  end

  def data_feed
    get_logos

    @feeds_graphic = graphics_folder + 'feeds.png'
  end

  def salesforce_integration
    get_logos

    @sfdc_graphic = graphics_folder + 'mightysignal_plus_salesforce.png'
    @account_graphic = graphics_folder + 'sfdc_account.gif'
    @reporting_graphic = graphics_folder + 'sfdc_reporting.gif'
    @export_graphic = graphics_folder + 'sfdc_export.gif'
    @sync_graphic = graphics_folder + 'sync.png'
  end

  def lead_generation
    get_creative
    get_logos

    @live_scan_graphic = graphics_folder + 'live_scan.png'
    @explore_graphic = graphics_folder + 'explore.png'
    @new_advertisers_graphic = graphics_folder + 'new_advertisers.png'
    @newcomers_graphic = graphics_folder + 'newcomers.png'
  end

  def abm
    get_logos

    @sfdc_graphic = graphics_folder + 'mightysignal_plus_salesforce.png'
    @sales_graphic = graphics_folder + 'hunting.svg'
    @marketing_graphic = graphics_folder + 'fishing.svg'
    @customer_success_graphic = graphics_folder + 'thumbs_up.svg'
    @learning_graphic = graphics_folder + 'learning.svg'

    @abm4m_post_0 = buttercms_post_path('introducing-abm4m-account-based-marketing-for-mobile')
  end

  def sdk_intelligence
    get_logos

    @competitor_graphic = graphics_folder + 'track_competitor.svg'
    @gaps_graphic = graphics_folder + 'puzzle.svg'
    @future_graphic = graphics_folder + 'crystal_ball.svg'
    @networking_icon = icons_folder + 'networking.svg'
  end

  def user_acquisition
    redirect_to root_path

    # maybe add this all back later
    # get_logos

    # @game_ad_graphic = graphics_folder + 'game_ad.png'
    # @target_graphic = graphics_folder + 'target.jpg'
    # @ad_network_graphic = graphics_folder + 'ad_network.png'
  end

  def lead_generation_ad_affiliate_networks
    get_creative

    @logos = [
        {image: 'taptica_color.png', width: 200},
        {image: 'verizon_color.png', width: 200},
        {image: 'liftoff_color.png', width: 200}
    ].each {|logo| logo[:image] = '/lib/images/logos/' + logo[:image]}

    @new_advertisers_graphic = graphics_folder + 'new_advertisers.png'
    @ad_attribution_graphic = graphics_folder + 'ad_attribution.png'
    @newcomers_graphic = graphics_folder + 'newcomers.png'
    @funnel_icon = icons_folder + 'funnel.svg'
  end

  def subscribe
    # TODO: we are no longer using Salesforce so this should be removed
    message = params[:message]
    if message == 'Timeline'
      destination = timeline_path(form: 'timeline')
    else
      destination = top_ios_sdks_path(form: 'top-ios-sdks')
    end

    if params[:email].present?
      lead_data = {email: params[:email], message: message, lead_source: message}

      ad_source = params['ad_source']
      lead_data.merge!(lead_source: ad_source) if ad_source.present?

      lead_data[:utm_source] = current_visit.utm_source
      lead_data[:utm_medium] = current_visit.utm_source
      lead_data[:utm_campaign] = current_visit.utm_campaign
      lead_data[:referrer] = current_visit.referrer
      lead_data[:referring_domain] = current_visit.referring_domain

      Lead.create_lead(lead_data)
      ahoy.track "Submitted subscribe", request.path_parameters
      flash[:success] = "We will be in touch soon!"
    else
      flash[:error] = "Please enter your email"
    end
    redirect_to destination
  end

  def contact_us
    if Rails.env.development? || verify_recaptcha
      lead_data = lead_data_from_params
      lead_data[:lead_source] = 'Web Form'
      lead_data[:web_form_button_id] = params['button_id']
      puts "lead_data: #{lead_data}"
      Lead.create_lead(lead_data)
      ahoy.track "Submitted contact us", request.path_parameters
      redirect_to well_be_in_touch_path(form: 'lead')
      return
    end
    redirect_to root_path(form: 'lead')
  end

  def well_be_in_touch
  end

  def get_sdk_icon
    id = params['id']
    platform = params['platform']
    favicon = platform === 'ios' ? IosSdk.find(id).favicon : AndroidSdk.find(id).favicon
    redirect_to favicon
  end

  protected

  def lead_data_from_params
    puts "PARAMS: #{params}"

    first_name = params['first_name']
    last_name = params['last_name']
    email = params['email']
    company = params['company']
    phone = params['phone']
    crm = params['crm']
    sdk = params['sdk']
    message = params['message']
    ad_source = params['ad_source']
    creative = params['creative']

    lead_data = params.slice(:first_name, :last_name, :company, :email, :phone, :crm, :sdk, :message, :ad_source, :creative, :app_identifier, :app_platform, :app_name, :app_id)
    lead_data[:utm_source] = current_visit.utm_source
    lead_data[:utm_medium] = current_visit.utm_source
    lead_data[:utm_campaign] = current_visit.utm_campaign
    lead_data[:referrer] = current_visit.referrer
    lead_data[:referring_domain] = current_visit.referring_domain

    if company.blank?
      email_regex = /@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      lead_data[:company] = email.match(email_regex).to_s[1..-1]
    end

    lead_data
  end

  def graphics_folder
    '/lib/images/graphics/'
  end

  def icons_folder
    '/lib/images/icons/'
  end

  def get_logos
    @logos = [
        {image: 'leanplum_color.png', width: 170},
        {image: 'taptica_color.png', width: 170},
        {image: 'zendesk_color.png', width: 170},
        {image: 'adobe_color.png', width: 170},
        {image: 'amplitude_color.png', width: 170},
        {image: 'verizon_color.png', width: 170}
    ].each {|logo| logo[:image] = '/lib/images/logos/' + logo[:image]}
  end

  def get_creative
    creative = params[:creative]

    @creative = "/lib/images/creatives/#{creative}.png" if creative.present?
  end

  def privacy
  end

  private

  def publisher_hot_store
    @publisher_hot_store ||= PublisherHotStore.new
  end

  def apps_hot_store
    @apps_hot_store ||= AppHotStore.new
  end
  
  def sdks_hot_store
    @sdks_hot_store ||= SdkHotStore.new
  end
  
  def sdk_categories_hot_store
    @sdk_categories_hot_store ||= SdkCategoryHotStore.new
  end

  def last_n_months(n)
    (DateTime.now-n.months..DateTime.now-1.month).map{|d| "#{d.year}-#{d.strftime('%m')}-01"}.uniq
  end
  
  def get_top(num, sdks)
    pre_sort = sdks.inject({}) do |hash, sdk|
      hash[sdk['id']] = get_last(1, sdk['apps_over_time']).flatten.last
      hash
    end
    pre_sort.sort_by {|k, v| -v}.first(num).to_h.keys
  end

  def get_last(num, chart_data)
    months = last_n_months(num)
    values = Array.new(num+1) { 0 }
    months_json = Hash[months.zip(values)]
    hotstore_json = JSON.parse(chart_data) rescue {}
    chart_json = months_json.merge(hotstore_json)
    chart_json.delete("#{Time.now.year}-#{Time.now.strftime('%m')}-01")
    chart_json.sort_by{ |k,_| k.to_s.to_date }.reverse.first(num)
  end

  def simplify_json_app(app)
    OpenStruct.new({
                       icon_url: app['icon_url'],
                       name: app['name'],
                       app_identifier: app['app_identifier']
                       # app_store_url: app['app_store_url'].present? ? app['app_store_url'] : "https://ui-avatars.com/api/?background=64c5e0&color=fff&name=#{app['name']}"
                   })
  end

end
