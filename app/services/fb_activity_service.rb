class FbActivityService
  class << self

    def simulate
      Slackiq.message('Starting to simulate facebook activity', webhook_name: :main)

      job = FbActivityJob.create!(notes: "Simulating user activity for all accounts")
      FbAccount.where(flagged: false, browsable: true).each do |account|
        FbActivityServiceWorker.new.perform(job.id, account.id) # do this synchronously...only want 1 instance of firefox at a time
      end

      Slackiq.notify(webhook_name: :background, title: 'Facebook Activity Complete', accounts: FbAccount.count, successes: job.fb_activities.count, failures: job.fb_activity_exceptions.count, likes: job.fb_activities.pluck(:likes).inject(:+), statuses: job.fb_activities.where.not(status: nil).count)
    end
  end
end