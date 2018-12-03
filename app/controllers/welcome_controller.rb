class WelcomeController < ApplicationController

  protect_from_forgery except: :contact_us
  caches_action :top_ios_sdks, :top_android_sdks, :top_android_apps, :top_ios_apps, cache_path: Proc.new {|c| c.request.url }, expires_in: 24.hours

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
    ].each{|logo| logo[:image] =  '/lib/images/logos/' + logo[:image]}.sample(5)

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
      filter: { term: { user_base: 'elite' } }
    ).boost_factor(
      2,
      filter: { term: { user_base: 'strong' } }
    ).boost_factor(
      1,
      filter: { term: { user_base: 'moderate' } }
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
    case params[:platform]
    when 'ios'
      app = IosApp.find_by_app_identifier(params[:app_identifier])
    when 'google-play'
      app = AndroidApp.find_by_app_identifier(params[:app_identifier])
    end
    #@app = app.as_external_dump_json
    @app = {"id"=>339329, "name"=>"miAIEP", "price"=>0, "seller_url"=>"http://aiep.cl/", "current_version"=>"5.2.0", "released"=>"Mon, 12 Nov 2018", "in_app_purchases"=>false, "required_android_version"=>"4.1 and up", "content_rating"=>"Everyone", "seller"=>"Moofwd", "in_app_purchase_min"=>nil, "in_app_purchase_max"=>nil, "downloads_min"=>100000, "downloads_max"=>500000, "icon_url"=>"https://lh3.googleusercontent.com/OhSNFLNUwu3bpO83d9ZJYhpxfnm68no5unOEGAsxlmY-cWAJTMOgW71txIW_v2J3oCM=s180", "categories"=>[{:id=>"EDUCATION", :name=>"Education"}], "publisher"=>{"name"=>"Moofwd", "id"=>100901, "platform"=>"android"}, "platform"=>"android", "google_play_id"=>"com.moofwd.mooestroaiep", "user_base"=>"strong", "last_updated"=>"2018-11-12", "all_version_rating"=>0.36e1, "all_version_ratings_count"=>3073, "description"=>"AIEP Mobile, es una aplicación que forma parte de Instituto Profesional AIEP. Esta iniciativa tiene por objeto optimizar los procesos de comunicación entre estudiantes y docentes. Esta aplicación móvil fue creada para que puedas obtener toda la información que necesitas como notas y mucho más, desde cualquier lugar y cuando tú quieras. De esta forma AIEP Mobile te permite acceder las 24 horas del día, los 7 días de la semana, permitiéndote administrar tu tiempo de mejor manera, con toda la información que necesitas para tu proceso académico en AIEP.", "installed_sdks"=>[{"id"=>142, "name"=>"Google Analytics", "last_seen_date"=>"Fri, 16 Nov 2018 14:34:14 PST -08:00", "first_seen_date"=>"Tue, 20 Oct 2015 18:02:26 PDT -07:00", "categories"=>["Analytics"]}, {"id"=>54835, "name"=>"square-picasso", "last_seen_date"=>"Fri, 16 Nov 2018 14:34:14 PST -08:00", "first_seen_date"=>"Tue, 20 Oct 2015 18:02:26 PDT -07:00", "categories"=>[]}, {"id"=>4485, "name"=>"Gson", "last_seen_date"=>"Fri, 16 Nov 2018 14:34:14 PST -08:00", "first_seen_date"=>"Fri, 17 Mar 2017 15:30:07 PDT -07:00", "categories"=>[]}, {"id"=>54836, "name"=>"squareup-okhttp", "last_seen_date"=>"Fri, 16 Nov 2018 14:34:14 PST -08:00", "first_seen_date"=>"Fri, 17 Mar 2017 15:30:07 PDT -07:00", "categories"=>["Networking"]}, {"id"=>54837, "name"=>"square-okio", "last_seen_date"=>"Fri, 16 Nov 2018 14:34:14 PST -08:00", "first_seen_date"=>"Fri, 17 Mar 2017 15:30:07 PDT -07:00", "categories"=>[]}, {"id"=>54827, "name"=>"leolin-shortcutbadger", "last_seen_date"=>"Fri, 16 Nov 2018 14:34:14 PST -08:00", "first_seen_date"=>"Fri, 16 Nov 2018 14:34:14 PST -08:00", "categories"=>[]}], "uninstalled_sdks"=>[{"id"=>3026, "name"=>"Zxing", "last_seen_date"=>"Sat, 12 Nov 2016 22:40:24 PST -08:00", "first_seen_date"=>"Tue, 20 Oct 2015 18:02:26 PDT -07:00", "first_unseen_date"=>"Fri, 17 Mar 2017 15:30:07 PDT -07:00", "categories"=>["Utilities"]}, {"id"=>54828, "name"=>"firebase-appindexing", "last_seen_date"=>"Sat, 12 Nov 2016 22:40:24 PST -08:00", "first_seen_date"=>"Tue, 20 Oct 2015 18:02:26 PDT -07:00", "first_unseen_date"=>"Fri, 17 Mar 2017 15:30:07 PDT -07:00", "categories"=>["Deep-Linking", "App Platform"]}, {"id"=>54830, "name"=>"Google-Admob", "last_seen_date"=>"Sat, 12 Nov 2016 22:40:24 PST -08:00", "first_seen_date"=>"Tue, 20 Oct 2015 18:02:26 PDT -07:00", "first_unseen_date"=>"Fri, 17 Mar 2017 15:30:07 PDT -07:00", "categories"=>["Monetization", "Ad-Mediation"]}], "mobile_priority"=>"high", "developer_google_play_identifier"=>"Moofwd", "ratings_history"=>[{"start_date"=>"2016-09-20T13:52:02.000-07:00", "stop_date"=>"2016-09-20T13:52:02.000-07:00", "ratings_all_count"=>2030, "ratings_all_stars"=>"3.72"}, {"start_date"=>"2016-09-24T15:22:40.000-07:00", "stop_date"=>"2016-09-24T15:22:40.000-07:00", "ratings_all_count"=>2032, "ratings_all_stars"=>"3.72"}, {"start_date"=>"2016-10-02T00:04:32.000-07:00", "stop_date"=>"2016-10-02T00:04:32.000-07:00", "ratings_all_count"=>2040, "ratings_all_stars"=>"3.72"}, {"start_date"=>"2016-10-09T16:14:46.000-07:00", "stop_date"=>"2016-10-09T16:14:46.000-07:00", "ratings_all_count"=>2045, "ratings_all_stars"=>"3.72"}, {"start_date"=>"2016-10-15T23:08:03.000-07:00", "stop_date"=>"2016-10-15T23:08:03.000-07:00", "ratings_all_count"=>2054, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-10-22T20:46:56.000-07:00", "stop_date"=>"2016-10-22T20:46:56.000-07:00", "ratings_all_count"=>2055, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-10-25T17:06:12.000-07:00", "stop_date"=>"2016-10-25T17:06:12.000-07:00", "ratings_all_count"=>2056, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-10-29T02:30:45.000-07:00", "stop_date"=>"2016-10-29T02:30:45.000-07:00", "ratings_all_count"=>2061, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-11-06T13:12:53.000-08:00", "stop_date"=>"2016-11-06T13:12:53.000-08:00", "ratings_all_count"=>2069, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-11-11T16:47:28.000-08:00", "stop_date"=>"2016-11-11T16:47:28.000-08:00", "ratings_all_count"=>2100, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-11-20T09:53:14.000-08:00", "stop_date"=>"2016-11-20T09:53:14.000-08:00", "ratings_all_count"=>2142, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-11-28T11:49:04.000-08:00", "stop_date"=>"2016-11-28T11:49:04.000-08:00", "ratings_all_count"=>2155, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-12-04T23:20:27.000-08:00", "stop_date"=>"2016-12-04T23:20:27.000-08:00", "ratings_all_count"=>2167, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-12-11T02:43:26.000-08:00", "stop_date"=>"2016-12-11T02:43:26.000-08:00", "ratings_all_count"=>2172, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-12-19T19:39:41.000-08:00", "stop_date"=>"2016-12-19T19:39:41.000-08:00", "ratings_all_count"=>2181, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2016-12-26T20:53:03.000-08:00", "stop_date"=>"2016-12-26T20:53:03.000-08:00", "ratings_all_count"=>2190, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-01-02T12:24:39.000-08:00", "stop_date"=>"2017-01-02T12:24:39.000-08:00", "ratings_all_count"=>2194, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-01-11T18:12:26.000-08:00", "stop_date"=>"2017-01-11T18:12:26.000-08:00", "ratings_all_count"=>2200, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-01-16T14:03:31.000-08:00", "stop_date"=>"2017-01-16T14:03:31.000-08:00", "ratings_all_count"=>2204, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-01-23T13:25:23.000-08:00", "stop_date"=>"2017-01-23T13:25:23.000-08:00", "ratings_all_count"=>2213, "ratings_all_stars"=>"3.72"}, {"start_date"=>"2017-01-30T11:06:04.000-08:00", "stop_date"=>"2017-01-30T11:06:04.000-08:00", "ratings_all_count"=>2229, "ratings_all_stars"=>"3.72"}, {"start_date"=>"2017-02-06T11:06:13.000-08:00", "stop_date"=>"2017-02-06T11:06:13.000-08:00", "ratings_all_count"=>2241, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-02-13T11:14:44.000-08:00", "stop_date"=>"2017-02-13T11:14:44.000-08:00", "ratings_all_count"=>2242, "ratings_all_stars"=>"3.72"}, {"start_date"=>"2017-02-18T16:42:39.000-08:00", "stop_date"=>"2017-02-18T16:42:39.000-08:00", "ratings_all_count"=>2249, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-03-06T13:21:36.000-08:00", "stop_date"=>"2017-03-06T13:21:36.000-08:00", "ratings_all_count"=>2274, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-03-14T16:01:40.000-07:00", "stop_date"=>"2017-03-14T16:01:40.000-07:00", "ratings_all_count"=>2305, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-03-20T12:03:41.000-07:00", "stop_date"=>"2017-03-20T12:03:41.000-07:00", "ratings_all_count"=>2316, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-03-27T12:01:29.000-07:00", "stop_date"=>"2017-03-27T12:01:29.000-07:00", "ratings_all_count"=>2327, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-04-03T12:00:37.000-07:00", "stop_date"=>"2017-04-03T12:00:37.000-07:00", "ratings_all_count"=>2336, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-04-10T12:03:16.000-07:00", "stop_date"=>"2017-04-10T12:03:16.000-07:00", "ratings_all_count"=>2340, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-04-17T12:50:15.000-07:00", "stop_date"=>"2017-04-17T12:50:15.000-07:00", "ratings_all_count"=>2342, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-04-19T21:14:29.000-07:00", "stop_date"=>"2017-04-19T21:14:29.000-07:00", "ratings_all_count"=>2345, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-04-23T19:09:33.000-07:00", "stop_date"=>"2017-04-23T19:09:33.000-07:00", "ratings_all_count"=>2349, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-04-24T21:11:01.000-07:00", "stop_date"=>"2017-04-24T21:11:01.000-07:00", "ratings_all_count"=>2351, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-04-25T21:40:25.000-07:00", "stop_date"=>"2017-04-30T18:28:29.000-07:00", "ratings_all_count"=>2353, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-05-08T16:56:36.000-07:00", "stop_date"=>"2017-05-09T04:41:38.000-07:00", "ratings_all_count"=>2354, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-05-11T06:18:59.000-07:00", "stop_date"=>"2017-05-11T06:18:59.000-07:00", "ratings_all_count"=>2358, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-05-16T17:47:23.000-07:00", "stop_date"=>"2017-05-18T10:55:02.000-07:00", "ratings_all_count"=>2359, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-05-25T06:29:15.000-07:00", "stop_date"=>"2017-05-25T06:29:15.000-07:00", "ratings_all_count"=>2364, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-06-01T06:22:23.000-07:00", "stop_date"=>"2017-06-01T06:22:23.000-07:00", "ratings_all_count"=>2368, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-06-08T21:44:17.000-07:00", "stop_date"=>"2017-06-08T21:44:17.000-07:00", "ratings_all_count"=>2374, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-06-15T06:18:48.000-07:00", "stop_date"=>"2017-06-15T06:18:48.000-07:00", "ratings_all_count"=>2380, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-06-22T06:18:10.000-07:00", "stop_date"=>"2017-06-22T06:18:10.000-07:00", "ratings_all_count"=>2381, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-06-29T06:22:26.000-07:00", "stop_date"=>"2017-06-29T06:22:26.000-07:00", "ratings_all_count"=>2384, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-07-06T06:18:15.000-07:00", "stop_date"=>"2017-07-06T06:18:15.000-07:00", "ratings_all_count"=>2390, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-07-13T06:12:28.000-07:00", "stop_date"=>"2017-07-13T06:12:28.000-07:00", "ratings_all_count"=>2392, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-07-14T16:19:43.000-07:00", "stop_date"=>"2017-07-16T18:12:08.000-07:00", "ratings_all_count"=>2394, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-07-20T06:15:26.000-07:00", "stop_date"=>"2017-07-23T18:17:52.000-07:00", "ratings_all_count"=>2398, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-07-27T06:12:40.000-07:00", "stop_date"=>"2017-07-27T06:12:40.000-07:00", "ratings_all_count"=>2400, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-07-30T18:08:43.000-07:00", "stop_date"=>"2017-07-30T18:08:43.000-07:00", "ratings_all_count"=>2401, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-08-03T06:06:57.000-07:00", "stop_date"=>"2017-08-03T06:06:57.000-07:00", "ratings_all_count"=>2402, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-08-06T18:08:34.000-07:00", "stop_date"=>"2017-08-06T18:08:34.000-07:00", "ratings_all_count"=>2406, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-08-10T06:06:48.000-07:00", "stop_date"=>"2017-08-13T18:08:02.000-07:00", "ratings_all_count"=>2410, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-08-17T06:15:23.000-07:00", "stop_date"=>"2017-08-20T18:12:27.000-07:00", "ratings_all_count"=>2412, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-08-24T06:15:56.000-07:00", "stop_date"=>"2017-08-24T06:15:56.000-07:00", "ratings_all_count"=>2414, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-08-27T18:14:18.000-07:00", "stop_date"=>"2017-08-27T18:14:18.000-07:00", "ratings_all_count"=>2415, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-08-31T06:25:51.000-07:00", "stop_date"=>"2017-09-03T18:24:24.000-07:00", "ratings_all_count"=>2418, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-09-06T16:21:12.000-07:00", "stop_date"=>"2017-09-07T08:33:30.000-07:00", "ratings_all_count"=>2419, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-09-10T18:23:26.000-07:00", "stop_date"=>"2017-09-10T18:23:26.000-07:00", "ratings_all_count"=>2421, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-09-21T06:11:31.000-07:00", "stop_date"=>"2017-09-21T06:11:31.000-07:00", "ratings_all_count"=>2422, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-09-14T06:19:42.000-07:00", "stop_date"=>"2017-09-24T18:07:21.000-07:00", "ratings_all_count"=>2423, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-09-28T06:16:39.000-07:00", "stop_date"=>"2017-09-28T06:16:39.000-07:00", "ratings_all_count"=>2424, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-10-01T18:07:22.000-07:00", "stop_date"=>"2017-10-01T18:07:22.000-07:00", "ratings_all_count"=>2428, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-10-05T06:10:12.000-07:00", "stop_date"=>"2017-10-05T06:10:12.000-07:00", "ratings_all_count"=>2429, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-10-08T18:09:01.000-07:00", "stop_date"=>"2017-10-09T19:00:12.000-07:00", "ratings_all_count"=>2430, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-10-10T08:50:14.000-07:00", "stop_date"=>"2017-10-12T06:16:16.000-07:00", "ratings_all_count"=>2431, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-10-15T18:10:26.000-07:00", "stop_date"=>"2017-10-15T18:10:26.000-07:00", "ratings_all_count"=>2432, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-10-19T06:35:54.000-07:00", "stop_date"=>"2017-10-19T06:35:54.000-07:00", "ratings_all_count"=>2435, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-10-22T18:03:39.000-07:00", "stop_date"=>"2017-10-22T18:03:39.000-07:00", "ratings_all_count"=>2436, "ratings_all_stars"=>"3.71"}, {"start_date"=>"2017-10-26T06:11:14.000-07:00", "stop_date"=>"2017-10-26T06:11:14.000-07:00", "ratings_all_count"=>2462, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-10-29T18:02:46.000-07:00", "stop_date"=>"2017-10-29T18:02:46.000-07:00", "ratings_all_count"=>2468, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-02T06:12:48.000-07:00", "stop_date"=>"2017-11-02T06:12:48.000-07:00", "ratings_all_count"=>2470, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-05T17:16:03.000-08:00", "stop_date"=>"2017-11-05T17:16:03.000-08:00", "ratings_all_count"=>2479, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-09T05:17:24.000-08:00", "stop_date"=>"2017-11-09T05:17:24.000-08:00", "ratings_all_count"=>2493, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-09T19:22:37.000-08:00", "stop_date"=>"2017-11-09T19:22:37.000-08:00", "ratings_all_count"=>2495, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-12T17:00:26.000-08:00", "stop_date"=>"2017-11-12T17:00:26.000-08:00", "ratings_all_count"=>2496, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-15T20:50:43.000-08:00", "stop_date"=>"2017-11-15T20:50:43.000-08:00", "ratings_all_count"=>2518, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-20T06:08:42.000-08:00", "stop_date"=>"2017-11-20T06:08:42.000-08:00", "ratings_all_count"=>2523, "ratings_all_stars"=>"3.7"}, {"start_date"=>"2017-11-23T06:03:56.000-08:00", "stop_date"=>"2017-11-23T06:03:56.000-08:00", "ratings_all_count"=>2526, "ratings_all_stars"=>"3.69"}, {"start_date"=>"2017-11-27T06:19:41.000-08:00", "stop_date"=>"2017-11-27T06:19:41.000-08:00", "ratings_all_count"=>2532, "ratings_all_stars"=>"3.69"}, {"start_date"=>"2017-11-30T16:18:09.000-08:00", "stop_date"=>"2017-11-30T16:18:09.000-08:00", "ratings_all_count"=>2533, "ratings_all_stars"=>"3.69"}, {"start_date"=>"2017-12-04T09:41:17.000-08:00", "stop_date"=>"2017-12-04T09:41:17.000-08:00", "ratings_all_count"=>2536, "ratings_all_stars"=>"3.69"}, {"start_date"=>"2017-12-07T09:39:08.000-08:00", "stop_date"=>"2017-12-07T09:39:08.000-08:00", "ratings_all_count"=>2540, "ratings_all_stars"=>"3.69"}, {"start_date"=>"2017-12-11T15:52:51.000-08:00", "stop_date"=>"2017-12-12T09:48:51.000-08:00", "ratings_all_count"=>2543, "ratings_all_stars"=>"3.69"}, {"start_date"=>"2017-12-14T19:36:58.000-08:00", "stop_date"=>"2017-12-14T19:36:58.000-08:00", "ratings_all_count"=>2544, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2017-12-18T09:50:16.000-08:00", "stop_date"=>"2017-12-18T09:50:16.000-08:00", "ratings_all_count"=>2545, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2017-12-21T09:57:02.000-08:00", "stop_date"=>"2017-12-21T09:57:02.000-08:00", "ratings_all_count"=>2546, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2017-12-25T09:45:37.000-08:00", "stop_date"=>"2017-12-25T09:45:37.000-08:00", "ratings_all_count"=>2547, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2017-12-28T09:56:24.000-08:00", "stop_date"=>"2017-12-28T09:56:24.000-08:00", "ratings_all_count"=>2550, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-01T09:50:59.000-08:00", "stop_date"=>"2018-01-04T10:09:53.000-08:00", "ratings_all_count"=>2551, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-08T10:05:15.000-08:00", "stop_date"=>"2018-01-08T10:05:15.000-08:00", "ratings_all_count"=>2554, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-11T11:32:14.000-08:00", "stop_date"=>"2018-01-11T11:32:14.000-08:00", "ratings_all_count"=>2556, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-15T10:39:39.000-08:00", "stop_date"=>"2018-01-15T10:39:39.000-08:00", "ratings_all_count"=>2557, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-18T11:20:07.000-08:00", "stop_date"=>"2018-01-18T11:20:07.000-08:00", "ratings_all_count"=>2560, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-22T10:09:26.000-08:00", "stop_date"=>"2018-01-22T10:09:26.000-08:00", "ratings_all_count"=>2561, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-25T10:34:39.000-08:00", "stop_date"=>"2018-01-25T10:34:39.000-08:00", "ratings_all_count"=>2563, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-01-29T10:38:04.000-08:00", "stop_date"=>"2018-01-29T10:38:04.000-08:00", "ratings_all_count"=>2566, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-01T11:30:01.000-08:00", "stop_date"=>"2018-02-01T11:30:01.000-08:00", "ratings_all_count"=>2568, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-05T11:21:52.000-08:00", "stop_date"=>"2018-02-05T11:21:52.000-08:00", "ratings_all_count"=>2570, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-08T11:45:35.000-08:00", "stop_date"=>"2018-02-08T11:45:35.000-08:00", "ratings_all_count"=>2571, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-12T11:16:36.000-08:00", "stop_date"=>"2018-02-12T11:16:36.000-08:00", "ratings_all_count"=>2573, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-15T12:15:35.000-08:00", "stop_date"=>"2018-02-19T11:21:56.000-08:00", "ratings_all_count"=>2574, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-22T12:48:52.000-08:00", "stop_date"=>"2018-02-22T12:48:52.000-08:00", "ratings_all_count"=>2579, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-26T11:29:56.000-08:00", "stop_date"=>"2018-02-26T11:29:56.000-08:00", "ratings_all_count"=>2582, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-02-28T00:10:03.000-08:00", "stop_date"=>"2018-02-28T00:10:03.000-08:00", "ratings_all_count"=>2583, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-03-01T11:53:10.000-08:00", "stop_date"=>"2018-03-01T11:53:10.000-08:00", "ratings_all_count"=>2585, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-03-05T12:03:24.000-08:00", "stop_date"=>"2018-03-05T12:03:24.000-08:00", "ratings_all_count"=>2589, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-03-08T12:54:59.000-08:00", "stop_date"=>"2018-03-08T12:54:59.000-08:00", "ratings_all_count"=>2593, "ratings_all_stars"=>"3.67"}, {"start_date"=>"2018-03-12T19:46:34.000-07:00", "stop_date"=>"2018-03-12T19:46:34.000-07:00", "ratings_all_count"=>2595, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-03-13T19:37:01.000-07:00", "stop_date"=>"2018-03-13T19:37:01.000-07:00", "ratings_all_count"=>2596, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-03-15T18:40:50.000-07:00", "stop_date"=>"2018-03-15T18:40:50.000-07:00", "ratings_all_count"=>2597, "ratings_all_stars"=>"3.68"}, {"start_date"=>"2018-03-19T20:45:59.000-07:00", "stop_date"=>"2018-03-19T20:45:59.000-07:00", "ratings_all_count"=>2602, "ratings_all_stars"=>"3.67"}, {"start_date"=>"2018-03-26T06:54:11.000-07:00", "stop_date"=>"2018-03-26T06:54:11.000-07:00", "ratings_all_count"=>2605, "ratings_all_stars"=>"3.67"}, {"start_date"=>"2018-03-29T10:13:23.000-07:00", "stop_date"=>"2018-03-29T10:13:23.000-07:00", "ratings_all_count"=>2607, "ratings_all_stars"=>"3.67"}, {"start_date"=>"2018-04-02T13:52:44.000-07:00", "stop_date"=>"2018-04-02T13:52:44.000-07:00", "ratings_all_count"=>2612, "ratings_all_stars"=>"3.67"}, {"start_date"=>"2018-04-05T14:02:01.000-07:00", "stop_date"=>"2018-04-05T14:02:01.000-07:00", "ratings_all_count"=>2615, "ratings_all_stars"=>"3.66"}, {"start_date"=>"2018-04-09T14:17:52.000-07:00", "stop_date"=>"2018-04-09T14:17:52.000-07:00", "ratings_all_count"=>2627, "ratings_all_stars"=>"3.66"}, {"start_date"=>"2018-04-12T16:32:51.000-07:00", "stop_date"=>"2018-04-12T16:32:51.000-07:00", "ratings_all_count"=>2630, "ratings_all_stars"=>"3.66"}, {"start_date"=>"2018-04-13T08:26:45.000-07:00", "stop_date"=>"2018-04-13T08:26:45.000-07:00", "ratings_all_count"=>2630, "ratings_all_stars"=>nil}, {"start_date"=>"2018-04-21T17:55:07.000-07:00", "stop_date"=>"2018-05-08T04:58:20.000-07:00", "ratings_all_count"=>2630, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-05-11T03:55:45.000-07:00", "stop_date"=>"2018-05-11T03:55:45.000-07:00", "ratings_all_count"=>2661, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-05-15T01:10:25.000-07:00", "stop_date"=>"2018-05-15T01:10:25.000-07:00", "ratings_all_count"=>2664, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-05-18T09:36:59.000-07:00", "stop_date"=>"2018-05-18T09:36:59.000-07:00", "ratings_all_count"=>2666, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-05-22T08:32:56.000-07:00", "stop_date"=>"2018-05-22T08:32:56.000-07:00", "ratings_all_count"=>2668, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-05-29T06:49:39.000-07:00", "stop_date"=>"2018-06-01T03:48:19.000-07:00", "ratings_all_count"=>2670, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-06-05T02:36:15.000-07:00", "stop_date"=>"2018-06-05T02:36:15.000-07:00", "ratings_all_count"=>2673, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-06-12T02:31:03.000-07:00", "stop_date"=>"2018-06-12T02:31:03.000-07:00", "ratings_all_count"=>2674, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-06-15T01:59:36.000-07:00", "stop_date"=>"2018-06-15T01:59:36.000-07:00", "ratings_all_count"=>2677, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-06-19T04:09:27.000-07:00", "stop_date"=>"2018-06-26T09:53:10.000-07:00", "ratings_all_count"=>2681, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-07-03T05:43:55.000-07:00", "stop_date"=>"2018-07-03T05:43:55.000-07:00", "ratings_all_count"=>2682, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-07-10T03:23:55.000-07:00", "stop_date"=>"2018-07-10T03:23:55.000-07:00", "ratings_all_count"=>2683, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-07-13T07:42:52.000-07:00", "stop_date"=>"2018-07-17T04:22:10.000-07:00", "ratings_all_count"=>2685, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-07-24T00:48:23.000-07:00", "stop_date"=>"2018-07-24T00:48:23.000-07:00", "ratings_all_count"=>2688, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-07-27T04:19:26.000-07:00", "stop_date"=>"2018-07-27T04:19:26.000-07:00", "ratings_all_count"=>2689, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-07-31T03:21:22.000-07:00", "stop_date"=>"2018-07-31T03:21:22.000-07:00", "ratings_all_count"=>2690, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-08-07T04:00:33.000-07:00", "stop_date"=>"2018-08-17T18:46:13.000-07:00", "ratings_all_count"=>2694, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-08-10T03:51:09.000-07:00", "stop_date"=>"2018-08-20T21:45:09.000-07:00", "ratings_all_count"=>2695, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-08-30T14:21:26.000-07:00", "stop_date"=>"2018-08-31T09:30:49.000-07:00", "ratings_all_count"=>2697, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-09-03T15:42:25.000-07:00", "stop_date"=>"2018-09-14T01:22:16.000-07:00", "ratings_all_count"=>2698, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-09-21T00:11:55.000-07:00", "stop_date"=>"2018-09-21T00:11:55.000-07:00", "ratings_all_count"=>2699, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-09-25T00:24:09.000-07:00", "stop_date"=>"2018-09-25T00:24:09.000-07:00", "ratings_all_count"=>2700, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-09-28T20:21:10.000-07:00", "stop_date"=>"2018-10-02T00:33:52.000-07:00", "ratings_all_count"=>2702, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-10-05T03:54:50.000-07:00", "stop_date"=>"2018-10-05T03:54:50.000-07:00", "ratings_all_count"=>2704, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-10-08T17:40:06.000-07:00", "stop_date"=>"2018-10-09T12:58:27.000-07:00", "ratings_all_count"=>2705, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-10-11T18:12:26.000-07:00", "stop_date"=>"2018-10-11T18:12:26.000-07:00", "ratings_all_count"=>2706, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-10-15T18:35:18.000-07:00", "stop_date"=>"2018-10-15T18:35:18.000-07:00", "ratings_all_count"=>2725, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-10-22T06:28:05.000-07:00", "stop_date"=>"2018-10-22T06:28:05.000-07:00", "ratings_all_count"=>2963, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-10-23T18:20:24.000-07:00", "stop_date"=>"2018-10-23T18:20:24.000-07:00", "ratings_all_count"=>2985, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-10-29T19:13:18.000-07:00", "stop_date"=>"2018-10-30T12:07:50.000-07:00", "ratings_all_count"=>3010, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-02T03:20:31.000-07:00", "stop_date"=>"2018-11-02T03:20:31.000-07:00", "ratings_all_count"=>3015, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-06T03:08:43.000-08:00", "stop_date"=>"2018-11-06T03:08:43.000-08:00", "ratings_all_count"=>3020, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-09T11:34:08.000-08:00", "stop_date"=>"2018-11-09T11:34:08.000-08:00", "ratings_all_count"=>3028, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-15T19:21:01.000-08:00", "stop_date"=>"2018-11-15T19:21:01.000-08:00", "ratings_all_count"=>3057, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-19T16:40:45.000-08:00", "stop_date"=>"2018-11-19T16:40:45.000-08:00", "ratings_all_count"=>3063, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-20T15:59:57.000-08:00", "stop_date"=>"2018-11-20T15:59:57.000-08:00", "ratings_all_count"=>3066, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-22T15:32:00.000-08:00", "stop_date"=>"2018-11-22T15:32:00.000-08:00", "ratings_all_count"=>3070, "ratings_all_stars"=>"3.6"}, {"start_date"=>"2018-11-26T17:45:39.000-08:00", "stop_date"=>nil, "ratings_all_count"=>3073, "ratings_all_stars"=>"3.6"}], "versions_history"=>[{"version"=>"4.1.1", "released"=>"2016-07-06"}, {"version"=>"4.2.0", "released"=>"2016-09-23"}, {"version"=>"4.3.0", "released"=>"2016-11-10"}, {"version"=>"4.4.0", "released"=>"2017-03-09"}, {"version"=>"4.5.0", "released"=>"2017-08-04"}, {"version"=>"4.6.0", "released"=>"2017-10-20"}, {"version"=>"4.6.3", "released"=>"2017-11-13"}, {"version"=>"4.6.4", "released"=>"2018-01-04"}, {"version"=>"4.6.5", "released"=>"2018-01-25"}, {"version"=>"5.0.0", "released"=>"2018-02-02"}, {"version"=>"5.1.0", "released"=>"2018-10-12"}, {"version"=>"5.2.0", "released"=>"2018-11-12"}], "downloads_history"=>[{"start_date"=>"2018-03-19T20:45:59.000-07:00", "stop_date"=>"2018-03-19T20:45:59.000-07:00", "downloads_min"=>nil, "downloads_max"=>nil}, {"start_date"=>"2016-09-20T13:52:02.000-07:00", "stop_date"=>nil, "downloads_min"=>100000, "downloads_max"=>500000}], "taken_down"=>false, "last_seen_ads_date"=>nil, "first_seen_ads_date"=>nil, "last_scanned_date"=>"2018-11-16T22:34:14Z", "first_scanned_date"=>"2015-10-21T01:02:26Z", "download_regions"=>[nil], "first_scraped"=>"2015-04-10T02:47:08-07:00"}
    puts "=====#{@app['installed_sdk_categories'].present?}"
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
                                 owner_id: top_200_ids, owner_type: 'IosApp', week: Time.now-1.month..Time.now).order('week desc')
    top_200_ids_a = AndroidAppRankingSnapshot.top_200_app_ids
    batches_a = WeeklyBatch.where(activity_type: [WeeklyBatch.activity_types[:install], WeeklyBatch.activity_types[:entered_top_apps]],
                                 owner_id: top_200_ids_a, owner_type: 'AndroidApp', week: Time.now-1.month..Time.now).order('week desc')

    batches_by_week = {}
    (batches_i + batches_a).each do |batch|
      if batches_by_week[batch.week]
        batches_by_week[batch.week] << batch
      else
        batches_by_week[batch.week] = [batch]
      end
    end

    batches_by_week.sort_by{|k,v| -(k.to_time.to_i)}
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
    @blog_post = "https://mightysignal.com/fastest-growing-android-sdks-blog-post"
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
    ].each{|logo| logo[:image] =  '/lib/images/logos/' + logo[:image]}

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
    # redirect_to(:back)
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
    ].each{|logo| logo[:image] =  '/lib/images/logos/' + logo[:image]}
  end

  def get_creative
    creative = params[:creative]

    @creative = "/lib/images/creatives/#{creative}.png" if creative.present?
  end
  
  def privacy
  end

end
