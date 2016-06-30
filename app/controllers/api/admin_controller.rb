class Api::AdminController < ApplicationController

  skip_before_filter  :verify_authenticity_token
  before_action :set_current_user, :authenticate_request
  before_action :authenticate_admin

  def index
    accounts = if @current_user.account.is_admin_account?
      Account.all
    else
      [@current_user.account]
    end
    render json: {accounts: accounts}
  end

  def update
    if params[:type] && params[:id] && params[:field]
      model = params[:type].constantize
      object = model.find(params[:id])
      # only allow changes for admin account users and admins managing their own users
      if @current_user.account.is_admin_account? || (params[:type] == "User" && object.account == @current_user.account)  
        if params[:value]
          object.update(params[:field] => params[:value])
        else
          object.toggle!(params[:field])
        end
      end
      render json: {account: object}
    else
      render :json => { :errors => "Could not update account" }, :status => 400
    end
  end

  def create_user
    if params[:email] && params[:account_id]
      account = Account.find(params[:account_id])
      # only allow changes for admin account users and admins managing their own users
      if @current_user.account.is_admin_account? || account == @current_user.account
        user = account.users.create(email: params[:email], password: SecureRandom.hex(8))
        EmailWorker.perform_async(:invite_user, user.id)
      end
    end

    if !user || user.errors.any?
      errors = user ? user.errors.full_messages.join(", ") : "Could not invite user"
      render json: { errors:  errors}, status: 400
    else
      render json: { user: user }
    end
  end

  def export_to_csv
    ios_apps = AppsIndex::IosApp.filter({"terms" => {"user_base" => ['elite', 'moderate', 'strong'], "execution" => "or"}})
    android_apps = AppsIndex::AndroidApp.filter({"terms" => {"user_base" => ['elite', 'moderate', 'strong'], "execution" => "or"}})

    top_ios_sdks = ios_apps.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]
    top_android_sdks = android_apps.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]
    top_ios_sdks_last_month = ios_apps.filter({"range" => {"released" => {'format' => 'date_time', 'gte' => 'now-30d/d'}}}).aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]
    
    # top gaming sdks
    ios_categories = ["Games"]
    android_categories = ["Games"] + FilterService.android_gaming_categories + FilterService.android_family_categories
    
    ios_games = ios_apps.filter({"terms" => {"categories" => ios_categories, "execution" => "or"}})
    android_games = android_apps.filter({"terms" => {"categories" => android_categories, "execution" => "or"}})
    top_ios_game_sdks = ios_games.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]
    top_android_game_sdks = android_games.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]
    top_ios_game_sdks_last_month = ios_games.filter({"range" => {"released" => {'format' => 'date_time', 'gte' => 'now-30d/d'}}}).aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]

    header = ["iOS SDK", "# Apps", "Description", "Website", "MightySignal URL", nil, "Android SDK", "# Apps", "Website", "MightySignal URL"]

    top_sdks_csv = CSV.generate do |csv|
      csv << ['Top Overall SDKs']
      csv << header
      for i in 0..100
        next unless top_ios_sdks[i] && top_android_sdks[i]
        ios_sdk = IosSdk.find(top_ios_sdks[i]["key"])
        android_sdk = AndroidSdk.find(top_android_sdks[i]["key"])
        csv << [ios_sdk.name, top_ios_sdks[i]["doc_count"], ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}", "",
                android_sdk.name, top_android_sdks[i]["doc_count"], android_sdk.website, "http://mightysignal.com/app/app#/sdk/android/#{android_sdk.id}"]
      end

      csv << []
      csv << ['Top SDKs Last 30 days']
      csv << ["iOS SDK", "# Apps", "Description", "Website", "MightySignal URL"]

      for i in 0..100
        next unless top_ios_sdks_last_month[i]
        ios_sdk = IosSdk.find(top_ios_sdks_last_month[i]["key"])
        csv << [ios_sdk.name, top_ios_sdks_last_month[i]["doc_count"], ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}"]
      end

      csv << []
      csv << ['Top Gaming SDKs']
      csv << header

      for i in 0..100
        next unless top_ios_game_sdks[i] && top_android_game_sdks[i]
        ios_sdk = IosSdk.find(top_ios_game_sdks[i]["key"])
        android_sdk = AndroidSdk.find(top_android_game_sdks[i]["key"])
        csv << [ios_sdk.name, top_ios_game_sdks[i]["doc_count"], ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}", "",
                android_sdk.name, top_android_game_sdks[i]["doc_count"], android_sdk.website, "http://mightysignal.com/app/app#/sdk/android/#{android_sdk.id}"]
      end

      csv << []
      csv << ['Top Gaming SDKs Last 30 days']
      csv << ["iOS SDK", "# Apps", "Description", "Website", "MightySignal URL"]

      for i in 0..100
        next unless top_ios_game_sdks_last_month[i]
        ios_sdk = IosSdk.find(top_ios_game_sdks_last_month[i]["key"])
        csv << [ios_sdk.name, top_ios_game_sdks_last_month[i]["doc_count"], ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}"]
      end
    end

    send_data top_sdks_csv
  end

  def create_account
    if params[:name]
      # only allow changes for admin account users and admins managing their own users
      if @current_user.account.is_admin_account?
        account = Account.create(name: params[:name])
        account.can_view_support_desk = false
        account.can_view_ad_spend = true
        account.can_view_sdks = true
        account.can_view_storewide_sdks = true
        account.can_view_exports = false
        account.can_view_ios_live_scan = true
        account.save
      end
    end

    if !account || account.errors.any?
      errors = account ? account.errors.full_messages.join(", ") : "Could not create account"
      render json: { errors:  errors}, status: 400
    else
      render json: { account: account }
    end
  end
end