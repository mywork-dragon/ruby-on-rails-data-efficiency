require 'test_helper'
require 'mocks/elasticsearch_mock'

class AppFilterTest < ActiveSupport::TestCase

  def setup
    @es_client = ElasticsearchMock.new
  end

  test 'generate query dsl' do
    filter = AppFilter.new(query_params: {'publisher_id' => '1,2,3', 'installed_sdk_id' => '123'}, platform: :ios)
    filter.generate_query_dsl!
    # so ugly
    assert_equal(
      {bool: {filter: [{terms: {'publisher_id' => ['1', '2', '3']}}, {terms: {'installed_sdks.id' => ['123']}}]}},
      filter.query_dsl)
  end

  test 'generate order dsl' do
    filter = AppFilter.new(query_params: {'order_by' => 'first_seen_ads_date'}, platform: :ios)
    filter.generate_order_dsl!
    assert_equal(
      [{'first_seen_ads' => :asc}, {:id => :asc}],
      filter.order_dsl
    )
  end

  test 'search!' do
    es_client = ElasticsearchMock.new
    es_client.add_response({:bool=>{:filter=>[{:terms=>{"publisher_id"=>["1", "2", "3"]}}]}}, [])
    filter = AppFilter.new(
      query_params: {'publisher_id' => '1,2,3', 'order_by' => 'first_seen_ads_date', 'page' => '3', 'page_size' => 15},
      platform: :ios,
      es_client: es_client
    )
    filter.generate_query_dsl!
    filter.generate_order_dsl!
    filter.run_query
    assert_equal({bool: {filter: [{terms: {'publisher_id' => ['1', '2', '3']}}]}}, filter.raw_result._query)
    assert_equal [{'first_seen_ads' => :asc}, {id: :asc}], filter.raw_result._order
    assert_equal 30, filter.raw_result._offset
    assert_equal 15, filter.raw_result._limit
  end

  test 'result' do
    es_client = ElasticsearchMock.new
    app = IosApp.create!(app_identifier: 1)
    es_client.add_response(
      {:bool=>{:filter=>[{:terms=>{"publisher_id"=>["1", "2", "3"]}}]}}, [{id: app.id}])

    app.es_client = ElasticsearchMock.new
    app.es_client.add_response(
      { term: { 'id' => app.id } },
      [{
        'id' => app.id,
        'installed_sdks' => [],
        'uninstalled_sdks' => []
      }])
    model = ModelMock.new
    model.register_query({id: [app.id]}, [app])
    filter = AppFilter.new(
      query_params: {'publisher_id' => '1,2,3', 'order_by' => 'first_seen_ads_date', 'page' => '3', 'page_size' => 15},
      platform: :ios,
      es_client: es_client,
      app_model: model
    )
    filter.search!
    result = filter.result
    assert_equal 3, result[:page]
    assert_equal 1, result[:results_count]
    assert_equal 1, result[:total_results_count]
    assert_equal 15, result[:page_size]
    assert_equal 1, result[:apps].count
    assert_equal app.id, result[:apps].first[:id]
  end

  ### Search Params subclass tests
  def params
    {
      'page' => '1',
      'page_size' => '20',
      'installed_sdk_id' => '5,10,3',
      'publisher_id' => '1',
      'not_supported' => '2'
    }
  end

  def oob_params
    {
      'page' => '-1',
      'page_size' => '5000000000'
    }
  end

  def subject(params)
    AppFilter::SearchParams.new(params, :ios)
  end

  #### Tests
  def test_identifies_page_params
    assert_equal subject(params).page_size, params['page_size'].to_i
    assert_equal subject(params).page, params['page'].to_i
  end

  def test_assigns_default_values
    refute_nil subject({}).page_size
    refute_nil subject({}).page
  end

  def test_bounds_inputs
    assert subject(oob_params).page > 0
    assert subject(oob_params).page_size < oob_params['page_size'].to_i
  end

  def test_shows_search_terms
    refute_nil subject(params).search_terms['publisher_id']
  end

  def test_split_multiple_into_array
    res = subject(params).search_terms['installed_sdk_id']
    assert_instance_of(Array, res)
    assert(res.count == params['installed_sdk_id'].split(',').count)
  end
end



# helper mock
class ModelMock

  class Unregistered < RuntimeError; end

  class AssociationMock
    def initialize(res)
      @res = res
    end

    def order(args)
      self # do nothing for now...
    end

    def map
      @res.map { |x| x.api_json }
    end
  end

  def initialize
    @registered = {}
  end

  def register_lookup(options_hash, answer)
    @registered[options_hash] = answer
  end

  def register_query(options_hash, answer)
    @registered[options_hash] = AssociationMock.new(answer)
  end

  def where(options)
    return @registered[options] if @registered[options]
    raise Unregistered, options
  end
end
