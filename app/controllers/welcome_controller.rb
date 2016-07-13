class WelcomeController < ApplicationController
  
  protect_from_forgery except: :contact_us
  caches_action :top_200, cache_path: Proc.new {|c| c.request.url.chomp("?form=top-200") }, expires_in: 12.hours

  layout "marketing" 
  
  def index
    @apps = IosApp.where(app_identifier: IosApp::WHITELISTED_APPS).to_a.shuffle

    # add Pokemon Go as first app because it's hot 
    pokemon_go_id = 2352590
    @apps.delete_if{ |ia| ia.id == pokemon_go_id }
    pokemon_go = IosApp.find(pokemon_go_id)
    @apps = [pokemon_go] + @apps
  end

  def app_sdks
    if request.format.js?
      @app = IosApp.find_by_app_identifier(params[:app_identifier])
      @sdks = @app.tagged_sdk_response(true)
    elsif !IosApp::WHITELISTED_APPS.include?(params[:app_identifier].to_i)
      redirect_to action: :index
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
      format.js
      format.html
    end
  end

  def top_200
    @last_updated = IosAppRankingSnapshot.last.created_at
    @tags = Tag.all
    @tag_label = "All"
    if params[:tag]
      @tag = Tag.find(params[:tag])
      @tag_label = @tag.name
      @sdks = @tag.ios_sdks
    else
      @sdks = Tag.includes(:ios_sdks).all.flat_map{|tag| tag.ios_sdks}
    end
    @sdks = Kaminari.paginate_array(@sdks.uniq.sort_by {|a| a.top_200_apps.size}.reverse).page(params[:page]).per(50)
  end

  def subscribe 
    if params[:email].present?
      ContactUsMailer.contact_us_email({email: params[:email]}).deliver
      flash[:success] = "We will be in touch soon!"
    else
      flash[:error] = "Please enter your email"
    end
    redirect_to top_200_path(form: 'top-200')
  end
  
  def contact_us
    first_name = params['first_name']
    last_name = params['last_name']
    email = params['email']
    company = params['company']
    phone = params['phone']
    crm = params['crm']
    sdk = params['sdk']
    message = params['message']

    lead_options = params.slice(:first_name, :last_name, :company, :email, :phone, :crm, :sdk, :message).merge({lead_source: "Web"})    
   
    if company.blank?   
      email_regex = /@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i   
      lead_options[:company] = email.match(email_regex).to_s[1..-1]   
    end
    
    #EmailWorker.perform_async(:contact_us, lead_options)
    ContactUsMailer.contact_us_email(lead_options).deliver
    flash[:success] = "We will be in touch soon!"
    redirect_to root_path(form: 'lead')
  end
  
end
