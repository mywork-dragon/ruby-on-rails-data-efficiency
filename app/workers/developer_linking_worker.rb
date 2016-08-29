class DeveloperLinkingWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: false

  def perform(method, *args)
    send(method.to_sym, *args)
  end

  def link_by_ios_developer_name(ios_developer_id)
    ios_developer = IosDeveloper.find(ios_developer_id)
    potential_matches = AndroidDeveloper.where(name: ios_developer.name)

    return if potential_matches.empty?

    rows = potential_matches.map do |android_developer|
      DeveloperLinkOption.new(
        ios_developer_id: ios_developer.id,
        android_developer_id: android_developer.id,
        method: :name
      )
    end

    DeveloperLinkOption.import rows
  end

  def link_by_ios_developer_websites(ios_developer_id)
  end
end
