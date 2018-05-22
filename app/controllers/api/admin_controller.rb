class Api::AdminController < ApplicationController

  skip_before_filter  :verify_authenticity_token
  before_action :set_current_user, :authenticate_request
  before_action :authenticate_admin, except: [:ios_reset_app_data]
  before_action :authenticate_admin_account, only: [:follow_sdks, :create_account, :resend_invite, :unlink_accounts, :generate_api_token, :delete_api_token, :update_api_token, :tag_major_app, :untag_major_app, :tag_major_publisher, :untag_major_publisher]

  def index
    accounts = if @current_user.account.is_admin_account? && params[:account_id].present?
      [Account.find(params[:account_id])]
    elsif @current_user.account.is_admin_account?
      Account.all
    else
      [@current_user.account]
    end
    render json: {accounts: accounts}
  end

  # for zapier integration
  def users_list
    aw = [:id, :name, :seats_count]
    uw = [:id, :last_active, :first_name, :last_name, :is_admin, :email, :created_at, :access_revoked]
    users = User.joins(:account).where(access_revoked: false).where.not("accounts.name like '%MightySignal%'").map do |u|
      res = u.slice(*uw)
      res[:account] = u.account.slice(*aw)
      res[:account][:activated_users] = u.account.users.where(access_revoked: false).count
      res
    end
    render json: users
  end

  def account_users
    account = Account.find(params[:account_id])
    if @current_user.account.is_admin_account? || account == @current_user.account
      render json: {users: account.users, following: account.following}
    else
      render json: {users: []}
    end
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

  def resend_invite
    if params[:user_id]
      EmailWorker.perform_async(:invite_user, params[:user_id])
      render json: {success: true}
    else
      render json: { errors: "Could not resend invite" }, status: 400
    end
  end

  def unlink_accounts
    if params[:user_id]
      user = User.find(params[:user_id])
      user.update_attributes(
        google_uid: nil,
        google_token: nil,
        linkedin_token: nil,
        linkedin_uid: nil,
        profile_url: nil
      )
      render json: {user: user}
    else
      render json: { errors: "Could not unlink accounts" }, status: 400
    end
  end

  def follow_sdks
    user_ids = params[:user_ids]
    account_ids = params[:account_ids]
    sdks = params[:sdks]
    sdks.map! {|sdk|
      case sdk["platform"]
      when 'iOS'
        IosSdk.find(sdk["id"])
      when 'Android'
        AndroidSdk.find(sdk["id"])
      end
    }

    sdks.each do |sdk|
      User.where(id: user_ids).each do |user|
        user.follow(sdk)
      end

      Account.where(id: account_ids).each do |account|
        account.follow(sdk)
        account.users.each do |user|
          user.follow(sdk)
        end
      end
    end

    render json: {success: true}
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
    ios_apps_last_month = ios_apps.filter({"range" => {"released" => {'format' => 'date_time', 'gte' => 'now-30d/d'}}})
    top_ios_sdks_last_month = ios_apps_last_month.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]

    # top gaming sdks
    ios_categories = ["Games"]
    android_categories = ["Games"] + FilterService.android_gaming_categories + FilterService.android_family_categories

    ios_games = ios_apps.filter({"terms" => {"categories" => ios_categories, "execution" => "or"}})
    android_games = android_apps.filter({"terms" => {"categories" => android_categories, "execution" => "or"}})
    top_ios_game_sdks = ios_games.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]
    top_android_game_sdks = android_games.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]
    ios_games_last_month = ios_games.filter({"range" => {"released" => {'format' => 'date_time', 'gte' => 'now-30d/d'}}})
    top_ios_game_sdks_last_month = ios_games_last_month.aggs({ top_sdks: {terms: { field: 'installed_sdks.id', size: 100 } }}).aggs["top_sdks"]["buckets"]

    header = ["iOS SDK", "# Apps", "% of Total Apps", "Description", "Website", "MightySignal URL", nil, "Android SDK", "# Apps", "% of Total Apps", "Website", "MightySignal URL"]

    top_sdks_csv = CSV.generate do |csv|
      csv << ["Top Overall SDKs from #{ios_apps.total_count} iOS apps and #{android_apps.total_count} Android apps"]
      csv << header
      for i in 0..100
        next unless top_ios_sdks[i] && top_android_sdks[i]
        ios_sdk = IosSdk.find(top_ios_sdks[i]["key"])
        android_sdk = AndroidSdk.find(top_android_sdks[i]["key"])
        csv << [ios_sdk.name, top_ios_sdks[i]["doc_count"], (top_ios_sdks[i]["doc_count"]/ios_apps.total_count.to_f) * 100, ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}", "",
                android_sdk.name, top_android_sdks[i]["doc_count"], (top_android_sdks[i]["doc_count"]/android_apps.total_count.to_f) * 100, android_sdk.website, "http://mightysignal.com/app/app#/sdk/android/#{android_sdk.id}"]
      end

      csv << []
      csv << ["Top SDKs from #{ios_apps_last_month.total_count} iOS apps released in last 30 days"]
      csv << ["iOS SDK", "# Apps", "% of Total Apps", "Description", "Website", "MightySignal URL"]

      for i in 0..100
        next unless top_ios_sdks_last_month[i]
        ios_sdk = IosSdk.find(top_ios_sdks_last_month[i]["key"])
        csv << [ios_sdk.name, top_ios_sdks_last_month[i]["doc_count"], (top_ios_sdks_last_month[i]["doc_count"]/ios_apps_last_month.total_count.to_f) * 100, ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}"]
      end

      csv << []
      csv << ["Top Gaming SDKs from #{ios_games.total_count} iOS games and #{android_games.total_count} Android games"]
      csv << header

      for i in 0..100
        next unless top_ios_game_sdks[i] && top_android_game_sdks[i]
        ios_sdk = IosSdk.find(top_ios_game_sdks[i]["key"])
        android_sdk = AndroidSdk.find(top_android_game_sdks[i]["key"])
        csv << [ios_sdk.name, top_ios_game_sdks[i]["doc_count"], (top_ios_game_sdks[i]["doc_count"]/ios_games.total_count.to_f) * 100, ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}", "",
                android_sdk.name, top_android_game_sdks[i]["doc_count"], (top_android_game_sdks[i]["doc_count"]/android_games.total_count.to_f) * 100, android_sdk.website, "http://mightysignal.com/app/app#/sdk/android/#{android_sdk.id}"]
      end

      csv << []
      csv << ["Top Gaming SDKs from #{ios_games_last_month.total_count} iOS games released in last 30 days"]
      csv << ["iOS SDK", "# Apps", "% of Total Apps", "Description", "Website", "MightySignal URL"]

      for i in 0..100
        next unless top_ios_game_sdks_last_month[i]
        ios_sdk = IosSdk.find(top_ios_game_sdks_last_month[i]["key"])
        csv << [ios_sdk.name, top_ios_game_sdks_last_month[i]["doc_count"], (top_ios_game_sdks_last_month[i]["doc_count"]/ios_games_last_month.total_count.to_f) * 100, ios_sdk.summary, ios_sdk.website, "http://mightysignal.com/app/app#/sdk/ios/#{ios_sdk.id}"]
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

  def ios_reset_app_data
    app_id = params['appId']
    ios_app = IosApp.find(app_id)
    ios_app.reset_app_data
    render json: {app_id: app_id}
  end

  def get_api_tokens
    unless @current_user.account.is_admin_account
      render json: @current_user.account.api_tokens.where(active: true)
    else
      render json: Account.find(params['account_id']).api_tokens
    end
  end

  def generate_api_token
    token = ApiToken.create!(
      account_id: params['account_id'],
      token: SecureRandom.hex,
      rate_window: params['rate_window'],
      rate_limit: params['rate_limit']
    )

    render json: token
  end

  def delete_api_token
    token = ApiToken.find(params['token_id'])
    token.destroy
    render json: token
  end

  def update_api_token
    token = ApiToken.find(params['id'])
    fields = JSON.parse(params['data'])
    token.update_attributes(fields)
    render json: token
  end

  def tag_major_app
    app_id = params[:appId]
    app = params[:platform] == "ios" ? IosApp.find(app_id) : AndroidApp.find(app_id)
    app.tag_as_major_app
    render json: app.to_json({ details: true })
  end

  def untag_major_app
    app_id = params[:appId]
    app = params[:platform] == "ios" ? IosApp.find(app_id) : AndroidApp.find(app_id)
    app.untag_as_major_app
    render json: app.to_json({ details: true })
  end

  def tag_major_publisher
    dev_id = params[:id]
    developer = params[:platform] == "ios" ? IosDeveloper.find(dev_id) : AndroidDeveloper.find(dev_id)
    developer.tag_as_major_publisher
    render json: { isMajorPublisher: developer.is_major_publisher? }
  end

  def untag_major_publisher
    dev_id = params[:id]
    developer = params[:platform] == "ios" ? IosDeveloper.find(dev_id) : AndroidDeveloper.find(dev_id)
    developer.untag_as_major_publisher
    render json: { isMajorPublisher: developer.is_major_publisher? }
  end

end
