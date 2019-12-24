class UserNotifyWorker
  include Sidekiq::Worker

  sidekiq_options queue: :mailers

  def perform(method, user_id)
    user = User.find(user_id)
    self.send(method.to_sym, user)
  rescue => e
    Bugsnag.notify(e)
  end

  def autopilot(user)
    AutopilotApi.post_contact(user.email)
  end

  def slack(user)
    Slackiq.message("USER ADDED! #{user.account.name} now has #{user.account.users.where(access_revoked: false).count} users and their limit is #{user.account.seats_count}.", webhook_name: :new_users)
  end

end
