class AppFilter

  attr_accessor :app_model, :es_client, :query_params, :platform, :raw_result, :query_dsl, :order_dsl
  attr_writer :result, :search_params

  def initialize(options = {})
    @app_model = options[:app_model]
    @es_client = options[:es_client]
    @query_params = options[:query_params]
    @platform = options[:platform]
  end

  def search_params
    @search_params ||= SearchParams.new(@query_params, @platform)
  end

  def search!
    generate_query_dsl!
    generate_order_dsl!
    run_query
  end

  def result
    return @result if @result
    app_ids = @raw_result.to_a.map(&:id)
    total_results_count = @raw_result.total_count
    apps = @app_model.where(id: app_ids)
    apps = apps.order("FIELD(id, #{app_ids.join(',')})") if app_ids.any?
    apps = apps.map { |a| a.api_json }

    @result = {
      apps: apps,
      page: search_params.page,
      page_size: search_params.page_size,
      results_count: app_ids.count,
      total_results_count: total_results_count,
      total_page_count: (1.0 * total_results_count / search_params.page_size).ceil
    }
  end

  def total_count
    @raw_result.total_count
  end

  def run_query
    result = @es_client.query(@query_dsl).order(@order_dsl)
    result = result.limit(search_params.page_size).offset((search_params.page - 1) * search_params.page_size)
    @raw_result = result
  end

  def generate_query_dsl!
    filter_terms = search_params.search_terms.keys.map do |term|
      {
        terms: { translate_term(term) => search_params.search_terms[term] }
      }
    end
    @query_dsl = {
      bool: {
        filter: filter_terms
      }
    }
  end

  def generate_order_dsl!
    dsl = search_params.order_terms.map do |order_term|
      if order_term[0] == '-'
        { translate_term(order_term[1..-1]) => :desc }
      else
        { translate_term(order_term) => :asc }
      end
    end

    if dsl.none? { |term| term.keys.first.to_sym == :id }
      dsl << { id: :asc }
    end
    @order_dsl = dsl
  end

  # allows for the translation of a search param term
  # to the query language for elasticsearch
  # ex. installed_sdk_id --> installed_sdks.id
  def translate_term(term)
    case term
    when 'installed_sdk_id'
      'installed_sdks.id'
    when 'has_ad_spend'
      'facebook_ads'
    when 'first_scanned_date'
      'first_scanned'
    when 'last_scanned_date'
      'last_scanned'
    when 'first_seen_ads_date'
      'first_seen_ads'
    when 'last_seen_ads_date'
      'last_seen_ads'
    when 'original_release_date'
      'released'
    else
      term # by default, do nothing
    end
  end

  class SearchParams
    SUPPORTED_PARAMS = {
      ios: %w(
        publisher_id
        installed_sdk_id
        has_ad_spend
      ),
      android: %w(
        publisher_id
        installed_sdk_id
      )
    }.freeze

    ORDER_PARAM = 'order_by'

    SUPPORTED_ORDER_VALUES = {
      ios: %w(
        first_seen_ads_date
        last_seen_ads_date
        first_scanned_date
        last_scanned_date
        last_updated
        original_release_date
      ),
      android: %w(
        first_scanned_date
        last_scanned_date
        last_updated
      )
    }.freeze

    PAGE_PARAMS = {
      'page' => {
        default: 1,
        min: 1,
        max: Float::INFINITY
      },
      'page_size' => {
        default: 25,
        min: 1,
        max: 50
      }
    }.freeze

    attr_reader :search_terms, :order_terms, :page, :page_size

    def initialize(params, platform)
      @params = params
      @platform = platform
      build_meta_info
      build_search_terms
      build_order_terms
    end

    private

    def build_search_terms
      spec = {}
      add_supported_params(spec)
      @search_terms = spec
    end

    def build_order_terms
      @order_terms = if @params[ORDER_PARAM]
        @params[ORDER_PARAM].split(',').select{|param|
          SUPPORTED_ORDER_VALUES[@platform].include?(param.sub('-', ''))
        }
      else
        []
      end
    end

    def build_meta_info
      @page = page_info_param('page')
      @page_size = page_info_param('page_size')
    end

    def page_info_param(key)
      param_info = PAGE_PARAMS[key]
      input = @params[key] ? @params[key].to_i : param_info[:default]
      # bound the value betwen ranges
      [param_info[:min], input, param_info[:max]].sort.second
    end

    def add_supported_params(spec)
      SUPPORTED_PARAMS[@platform].each do |key|
        spec[key] = @params[key].split(',') if @params[key]
      end
    end

  end
end
