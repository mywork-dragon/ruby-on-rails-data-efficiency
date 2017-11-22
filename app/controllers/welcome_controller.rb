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
      {image: 'microsoft.png', width: 160},
      # {image: 'ironsrc.png', width: 170},
      #{image: 'vungle.png', width: 125},
      #{image: 'realm.png', width: 135},
      #{image: 'neumob.png', width: 170},
      # {image: 'yahoo.png', width: 165},
      {image: 'appsflyer.png', width: 180},
      {image: 'mixpanel.png', width: 160},
      {image: 'zendesk.png', width: 170},
      {image: 'adobe.png', width: 160}
    ].each{|logo| logo[:image] =  '/lib/images/logos/' + logo[:image]}.sample(5)

    icons_folder = '/lib/images/icons/'
    @funnel_icon = icons_folder + 'funnel.svg'
    @networking_icon = icons_folder + 'networking.svg'
    @team_icon = icons_folder + 'team.svg'
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
      sdk_response = @app.sdk_response
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
    batches = WeeklyBatch.where(activity_type: [WeeklyBatch.activity_types[:install], WeeklyBatch.activity_types[:entered_top_apps]],
                                 owner_id: top_200_ids, owner_type: 'IosApp', week: Time.now-1.month..Time.now).order('week desc')
    batches_by_week = {}
    batches.each do |batch|
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

  def lead_generation
    get_logos

    @live_scan_graphic = graphics_folder + 'live_scan.png'
    @explore_graphic = graphics_folder + 'explore.png'
    @new_advertisers_graphic = graphics_folder + 'new_advertisers.png'
  end

  def business_intelligence
    get_logos

    @sfdc_graphic = graphics_folder + 'sfdc_integration.png'
    @api_graphic = graphics_folder + 'api.png'
    @feeds_graphic = graphics_folder + 'feeds.png'
  end

  def user_acquisition
    redirect_to root_path

    # maybe add this all back later
    # get_logos

    # @game_ad_graphic = graphics_folder + 'game_ad.png'
    # @target_graphic = graphics_folder + 'target.jpg'
    # @ad_network_graphic = graphics_folder + 'ad_network.png'
  end

  def subscribe
    message = params[:message]
    if message == 'Timeline'
      destination = timeline_path(form: 'timeline')
    else
      destination = top_ios_sdks_path(form: 'top-ios-sdks')
    end

    if params[:email].present?
      lead_data = {email: params[:email], message: message, lead_source: message}

      ad_source = params['ad_source']
      lead_data.merge!(ad_source: ad_source) if ad_source.present?

      Lead.create_lead(lead_data)
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

      Lead.create_lead(lead_data)
      redirect_to well_be_in_touch_path(form: 'lead')
      return
    end
    redirect_to root_path(form: 'lead')
  end

  def contact_us_from_modal
    lead_data = lead_data_from_params
    lead_data[:lead_source] = 'Web Form'
    lead_data[:web_form_button_id] = params['button_id']
    Lead.create_lead(lead_data)

    redirect_to well_be_in_touch_path
  end

  def well_be_in_touch
  end

  protected

  def lead_data_from_params
    first_name = params['first_name']
    last_name = params['last_name']
    email = params['email']
    company = params['company']
    phone = params['phone']
    crm = params['crm']
    sdk = params['sdk']
    message = params['message']
    ad_source = params['ad_source']

    lead_data = params.slice(:first_name, :last_name, :company, :email, :phone, :crm, :sdk, :message, :ad_source)

    if company.blank?
      email_regex = /@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      lead_data[:company] = email.match(email_regex).to_s[1..-1]
    end

    lead_data
  end

  def graphics_folder
    '/lib/images/graphics/'
  end

  def get_logos
    @logos = [
      {image: 'ironsrc_color.png', width: 170},
      {image: 'appsflyer_color.png', width: 170},
      {image: 'zendesk_color.png', width: 170},
      {image: 'adobe_color.png', width: 170},
      {image: 'amplitude_color.png', width: 170},
      {image: 'verizon_color.png', width: 170}
    ].each{|logo| logo[:image] =  '/lib/images/logos/' + logo[:image]}
  end

end
