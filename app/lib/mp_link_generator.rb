class MpLinkGenerator

  class InvalidFeature < RuntimeError; end

  SEGMENTATION_URL = 'https://mixpanel.com/report/633045/segmentation/#'

  def initialize(email)
    @email = email
  end

  def features
    feature_events.keys
  end

  def feature_events
    {
      timeline: [
        'Clicked Timeline Item',
        'Exported Timeline Item',
        'Added Country to Timeline',
        'Removed Country from Timeline',
        'Expanded Timeline Item'
      ],
      filtering: [
        'Filter Query Successful',
        'Filter Query Failed'
      ],
      live_scan: [
        'iOS Live Scan Success',
        'iOS Live Scan Failed',
        'Android Live Scan Success',
        'Android Live Scan Failed'
      ],
      ad_intelligence: [
        'Ad Intelligence Viewed',
        'App on Ad Intelligence Clicked'
      ],
      contacts: [
        'Contact Email Requested',
        'Exported Contacts CSV',
        'LinkedIn Link Clicked'
      ],
      ewok: [
        'Ewok App Page Viewed'
      ],
      search: [
        'Custom Search', 
        'SDK Custom Search'
      ]
    }
  end

  def feature_segmentation(feature, from_date, to_date)
    raise InvalidFeature unless features.include?(feature)
    events = feature_events[feature]

    SEGMENTATION_URL + query_string(events, from_date, to_date)
  end

  def query_string(events, from_date, to_date)
    params = [
      'action:segment',
      arb_event(events),
      'bool_op:and',
      'chart_analysis_type:linear',
      'chart_type:line',
      "from_date:#{date_diff(from_date)}",
      graph_params(events, from_date, to_date),
      ms_checked(events),
      ms_values(events),
      segfilter,
      "to_date:#{date_diff(to_date)}",
      'type:general',
      'unit:day'
    ].join(',')
    Addressable::URI.encode(params)
  end

  def joined_array(items)
    "!(#{items.map { |x| "'#{x}'" }.join(',')})"
  end

  def arb_event(events)
    "arb_event:#{joined_array(events)}"
  end

  def date_diff(date)
    (date - Date.today).to_i
  end

  def graph_params(events, from_date, to_date)
    params = [
      "event:#{joined_array(events)}",
      "from_date:'#{from_date.to_s}'",
      "to_date:'#{to_date.to_s}'",
      "type:general",
      "unit:day",
      "where:'(\"#{@email}\" in user[\"$email\"]) and (defined (user[\"$email\"]))'"
    ].join(',')
    "graph_params:(#{params})"
  end

  def ms_values(events)
    "ms_values:#{joined_array(events)}"
  end

  def ms_checked(events)
    arr = events.map { |x| "'#{x}':!t" }.join(',')
    "ms_checked:(#{arr})"
  end

  def segfilter
    inner_arr = [
      'dropdown_tab_index:2',
      "filter:(operand:'#{@email}',operator:in)",
      "property:(name:'$email',no_second_icon:!t,source:user,type:string)",
      'selected_property_type:string',
      'type:string'
    ].join(',')
    "segfilter:!((#{inner_arr}))"
  end
end
