class WelcomeController < ApplicationController
  include AppsHelper

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
    platform = params[:platform] == 'ios' ? 'ios' : 'android'
    app_identifier =  params[:app_identifier]
    @app = "#{platform.capitalize}App".constantize.find_by(app_identifier: app_identifier)
    @json_app = apps_hot_store.read(platform, @app.id)
    @json_publisher = publisher_hot_store.read(platform, @app.publisher.id)
    @top_apps = select_top_apps_from(@json_publisher['apps'], 5)
    most_recent_app = select_most_recent_app_from(@json_publisher['apps'])
    @last_update_date = latest_release_of(most_recent_app).to_date
    @latest_update = (Date.current - @last_update_date).to_i
    @sdks = @json_app['sdk_activity']
    @sdk_installed = @sdks.count { |sdk| sdk['installed'] }
    @sdk_uninstalled = @sdks.count { |sdk| !sdk['installed'] }
    @installed_sdk_categories = @sdks.reduce({}) do |memo, sdk|
      next memo unless sdk['installed'] && sdk['categories']
      sdk['categories'].each { |cat| memo[cat] ? memo[cat] += 1 : memo[cat] = 1 }
      memo
    end
    @uninstalled_sdk_categories = @sdks.reduce({}) do |memo, sdk|
      next memo unless !sdk['installed'] && sdk['categories']
      sdk['categories'].each { |cat| memo[cat] ? memo[cat] += 1 : memo[cat] = 1 }
      memo
    end
    @categories = @json_app['categories'].andand.map{|cat| cat['name']}
    ap @json_app.except('sdk_activity').except('ratings_history')
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

  private

  def publisher_hot_store
    @publisher_hot_store ||= PublisherHotStore.new
  end

  def apps_hot_store
    @apps_hot_store ||= AppHotStore.new
  end

end
