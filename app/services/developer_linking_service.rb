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

    def load_manual_app_developers
      batch = Sidekiq::Batch.new
      batch.description = 'Loading manual app developers'
      batch.on(:complete, 'DeveloperLinkingService#on_complete_manual_developers')

      batch.jobs do
        DeveloperLinkingWorker.perform_async(:load_manual_app_developers)
      end
    end

    def empty_app_developer_tables
      [AppDeveloper, AppDevelopersDeveloper].each do |model|
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model.table_name}")
      end
    end

    def empty_link_options
      [DeveloperLinkOption].each do |model|
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model.table_name}")
      end
    end

    def compare_results
      success = 0
      failures = 0
      success_developers = []
      failure_developers = []
      answers = load_answers
      answers.keys.each do |ios_developer_id|
        android_developer_id = answers[ios_developer_id]
        ios_developer = IosDeveloper.find(ios_developer_id)
        app_developer = ios_developer.app_developer

        if android_developer_id == -1
          if app_developer
            failure_developers << ios_developer
            failures += 1
          else
            success += 1
          end
        else
          if app_developer
            linked = app_developer.android_developers.find_by(id: android_developer_id)

            if linked
              if app_developers.android_developers.count + app_developers.ios_developers.count > 10
                failure_developers << ios_developer
                failures += 1
              else
                success += 1
              end
            else
              failure_developers << ios_developer
              failures += 1
            end
          else
            failure_developers << ios_developer
            failures += 1
          end
        end
      end

      puts "Successes: #{success}"
      puts "Failures: #{failures}"
      puts "%: #{100.0 * success / (success + failures)}"
      failure_developers
    end

    def load_answers
      links = File.open('app/lib/publisher_links.txt') {|f| f.read}
      ios_developer_ids = android_developer_ids = []
      links.split(/\n/).reduce({}) do |memo, line|
        parts = line.split.map(&:to_i)
        memo[parts[0]] = parts[1]
        memo
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

  def on_complete_manual_developers(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed loading manual developers')
  end
end
