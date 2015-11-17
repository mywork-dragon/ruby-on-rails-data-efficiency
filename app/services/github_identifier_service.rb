class GithubIdentifierService
  class << self

    def refresh_github_ids(null_only = false)
      query = "website REGEXP 'github.(com|io)'" + (null_only ? " and github_repo_identifier is NULL" : "")
      sdks = IosSdk.select(:id).where(query)

      if Rails.env.production?
        batch = Sidekiq::Batch.new
        batch.description = "populating github ids"
        batch.on(:complete, 'GithubIdentifierService#on_complete')

        batch.jobs do
          sdks.each do |sdk|
            GithubIdentifierServiceWorker.perform_async(sdk.id)
          end
        end
      else
        # just debugging, so only use a few
        sdks.each do |sdk|
          GithubIdentifierServiceWorker.new.perform(sdk.id)
        end
      end
      
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'GithubIdentifierService Completed')
  end
end