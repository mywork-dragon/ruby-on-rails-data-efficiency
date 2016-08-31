class DeveloperLinkingService
  class << self

    def build_app_developers
      batch = Sidekiq::Batch.new
      batch.description = 'Populating app developers'
      batch.on(:complete, 'DeveloperLinkingService#on_complete_app_developers')

      batch.jobs do
        DeveloperLinkingWorker.perform_async(:queue_link_options)
      end
    end

    def match_names
      batch = Sidekiq::Batch.new
      batch.description = 'Populating developer options'
      batch.on(:complete, 'DeveloperLinkingService#on_complete_match_names')

      batch.jobs do
        DeveloperLinkingWorker.perform_async(:queue_ios_developers, :link_by_ios_developer_name)
      end
    end

    def match_websites
      batch = Sidekiq::Batch.new
      batch.description = 'Populating developer options'
      batch.on(:complete, 'DeveloperLinkingService#on_complete_match_websites')

      batch.jobs do
        DeveloperLinkingWorker.perform_async(:queue_ios_developers, :link_by_ios_developer_websites)
      end
    end

    def fill_website_match_strings
      batch = Sidekiq::Batch.new
      batch.description = 'Populating website comparisons'
      batch.on(:complete, 'DeveloperLinkingService#on_complete_match_strings')

      batch.jobs do
        DeveloperLinkingWorker.perform_async(:queue_websites)
      end
    end

    def empty_app_developer_tables
      [AppDeveloper, AppDevelopersDeveloper].each do |model|
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model.table_name}")
      end
    end
  end

  def on_complete_app_developers(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Finished building app developers')
  end

  def on_complete_match_websites(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed website matching')
  end

  def on_complete_match_names(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed name matching')
  end

  def on_complete_match_strings(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed populating match strings')
  end
end
