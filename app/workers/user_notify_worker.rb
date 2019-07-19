class UserNotify
  include Sidekiq::Worker
  
  sidekiq_options queue: :default

  def perform(method, user)
    self.send(method.to_sym, user)
  end

  def autopilot(user)
    uri = URI.parse("https://api2.autopilothq.com/v1/trigger/0002/contact")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path)
    req['autopilotapikey'] = ENV['API_AUTOPILOT_KEY']
    req.body = { "contact": { "Email": user.email } }.to_json
    https.request(req)
  rescue  => e
    Bugsnag.notify(e)
  end

  def slack(user)
    Slackiq.message("USER ADDED! #{user.account.name} now has #{user.account.users.count} users and their limit is #{user.account.seats_count}.", webhook_name: :new_users)
  rescue  => e
    Bugsnag.notify(e)
  end
  
end