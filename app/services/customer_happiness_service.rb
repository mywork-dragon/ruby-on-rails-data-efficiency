class CustomerHappinessService
  extend Utils::Workers

  class << self

    def users_last_used_events(how_long_ago)
      self.new.users_last_used_events(how_long_ago)
    end

    def pull_mixpanel_data(from_date = 7.days.ago.to_date)
      delegate_perform(MixpanelPullWorker, from_date)
    end

  end

  # Call this to get the hash of users, their events, and when they were last used
  def users_last_used_events(how_long_ago)
    events = AnalyticsService::CustomerSuccess.export_for_events(events: events_to_query, how_long_ago: how_long_ago)

    e2f = event_to_feature

    ulue = {} # value to return

    events.each do |event|
      feature = e2f[event.try(:[], 'event')]
      next unless feature # next unless it's a valid event that we're tracking

      properties = event.try(:[], 'properties')
      next if properties.blank?

      email = properties.try(:[], 'distinct_id')
      next if email.blank?

      ulue[email] ||= {}

      epoch_time = properties.try(:[], 'time')
      next if epoch_time.blank?
      date = Time.at(epoch_time).to_date

      date_current = ulue[email][feature]

      ulue[email][feature] = date if date_current.nil? || date > date_current
    end

    ulue
  end

  def feature_names
    feature_to_events.keys
  end

  private

  # CHANGE FEATURE TO EVENTS MAPPINGS HERE
  def feature_to_events
    {
      timeline: ['Clicked Timeline Item', 'Exported Timeline Item', 'Added Country to Timeline', 'Removed Country from Timeline'],
      filtering: ['Filter Query Successful'],
      live_scan: ['iOS Live Scan Success', 'Android Live Scan Success'],
      ad_intelligence: ['Ad Intelligence Viewed'],
      contacts: ['Company Contacts Requested', 'Exported Contacts CSV', 'LinkedIn Link Clicked'],
      ewok: ['Ewok App Page Viewed'],
      search: ['Custom Search', 'SDK Custom Search']
    }
  end

  def events_to_query
    feature_to_events.values.flatten
  end

  # Invert and flatten the feature_to_events Hash so you're looking up by event instead of feature
  def event_to_feature
    event_to_feature_h = {}

    feature_to_events.each do |feature, events|
      events.each do |event|
        event_to_feature_h[event] = feature
      end
    end

    event_to_feature_h
  end

end
