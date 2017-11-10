require 'test_helper'
require 'mocks/mock_cached_query'
require 'mocks/redshift_base_mock'

class RedshiftRankingsAccessorTest < ActiveSupport::TestCase

  def setup
    @accessor = RedshiftRankingsAccessor.new
    @accessor.query_class_override = RedshiftBaseMock

    @mock_count_response = MockCachedQuery.new(return_value: [{
      "count" => 10
    }])

    @mock_trending_apps_response = MockCachedQuery.new(return_value: [{
      "app_identifier" => "com.terran.marine",
      "weekly_change" => 5,
      "monthly_change" => 0,
      "rank" => 3,
      "platform" => "android",
      "country" => "US",
      "category" => "GAMES",
      "ranking_type" => "paid"
    }, {
      "app_identifier" => "com.protoss.zealot",
      "weekly_change" => 10,
      "monthly_change" => -20,
      "rank" => 7,
      "platform" => "android",
      "country" => "FR",
      "category" => "BUSINESS",
      "ranking_type" => "free"
    }])

    @mock_newcomer_apps_response = MockCachedQuery.new(return_value: [{
      "app_identifier" => "com.terran.marine",
      "rank" => 3,
      "platform" => "android",
      "country" => "US",
      "category" => "GAMES",
      "ranking_type" => "paid",
      "created_at" => 1.day.ago
    }, {
      "app_identifier" => "123456",
      "rank" =>100,
      "platform" => "ios",
      "country" => "FR",
      "category" => "FITNESS",
      "ranking_type" => "free",
      "created_at" => 1.day.ago
    }, {
      "app_identifier" => "com.zerg.overlord",
      "rank" => 2020,
      "platform" => "android",
      "country" => "KR",
      "category" => "SPORTS",
      "ranking_type" => "grossing",
      "created_at" => 1.day.ago
    }])

    @mock_get_chart_response = MockCachedQuery.new(return_value: [{
      "app_identifier" => "com.zerg.hydralisk",
      "rank" => 1,
      "platform" => "android",
      "country" => "KR",
      "category" => "SPORTS",
      "ranking_type" => "grossing",
      "created_at" => 1.day.ago
    }, {
      "app_identifier" => "com.protoss.archon",
      "rank" => 2,
      "platform" => "android",
      "country" => "KR",
      "category" => "SPORTS",
      "ranking_type" => "grossing",
      "created_at" => 1.day.ago
    }])
  end

  test 'get_trending_default_params_test' do
    RedshiftBaseMock.set_result("SELECT * FROM daily_trends  WHERE ranking_type IN ('27','topselling_free','30','topselling_paid','38','topgrossing') AND weekly_change IS NOT NULL AND rank < 500 ORDER BY weekly_change DESC OFFSET 0 LIMIT 20", @mock_trending_apps_response)
    RedshiftBaseMock.set_result("SELECT COUNT(app_identifier) FROM daily_trends  WHERE ranking_type IN ('27','topselling_free','30','topselling_paid','38','topgrossing') AND weekly_change IS NOT NULL AND rank < 500", @mock_count_response)
    
    result = @accessor.get_trending

    assert_equal result["total"], 10
    assert_equal result["apps"][0]["app_identifier"], "com.terran.marine"
    assert_equal result["apps"][0]["rank"], 3
    assert_equal result["apps"][1]["app_identifier"], "com.protoss.zealot"
    assert_equal result["apps"][1]["rank"], 7
  end

  test 'get_trending_single_params_test' do
    RedshiftBaseMock.set_result("SELECT * FROM daily_trends  WHERE country IN ('143441','143442','US','FR') AND ranking_type IN ('27','topselling_free','30','topselling_paid','38','topgrossing') AND weekly_change IS NOT NULL AND rank < 500 ORDER BY weekly_change DESC OFFSET 0 LIMIT 20", @mock_trending_apps_response)
    RedshiftBaseMock.set_result("SELECT COUNT(app_identifier) FROM daily_trends  WHERE country IN ('143441','143442','US','FR') AND ranking_type IN ('27','topselling_free','30','topselling_paid','38','topgrossing') AND weekly_change IS NOT NULL AND rank < 500", @mock_count_response)
    
    result = @accessor.get_trending(countries: ["US", "FR"])

    assert_equal result["total"], 10
    assert_equal result["apps"][0]["app_identifier"], "com.terran.marine"
    assert_equal result["apps"][0]["rank"], 3
    assert_equal result["apps"][1]["app_identifier"], "com.protoss.zealot"
    assert_equal result["apps"][1]["rank"], 7
  end

  test 'get_trending_multiple_params_test' do
    RedshiftBaseMock.set_result("SELECT * FROM daily_trends  WHERE category IN ('36','OVERALL') AND ranking_type IN ('38','topgrossing') AND monthly_change IS NOT NULL AND rank < 20 ORDER BY monthly_change ASC OFFSET 10 LIMIT 5", @mock_trending_apps_response)
    RedshiftBaseMock.set_result("SELECT COUNT(app_identifier) FROM daily_trends  WHERE category IN ('36','OVERALL') AND ranking_type IN ('38','topgrossing') AND monthly_change IS NOT NULL AND rank < 20", @mock_count_response)
    
    result = @accessor.get_trending(categories: ["36", "OVERALL"], rank_types: ["grossing"], size: 5, page_num: 3, sort_by: "monthly_change", desc: false, max_rank: 20)

    assert_equal result["total"], 10
    assert_equal result["apps"][0]["app_identifier"], "com.terran.marine"
    assert_equal result["apps"][0]["rank"], 3
    assert_equal result["apps"][1]["app_identifier"], "com.protoss.zealot"
    assert_equal result["apps"][1]["rank"], 7
  end

  test 'get_trending_validate_params_test' do
    assert_raise do
      @accessor.get_trending(categories: ["36", "2v2 \"Noobs\" Only"], rank_types: ["grossing"], size: 5, page_num: 3, sort_by: "monthly_change", desc: false, max_rank: 20)
    end

    assert_raise do
      @accessor.get_trending(platforms: ["android", "Terran"], rank_types: ["grossing"], size: 5, page_num: 3, sort_by: "monthly_change", desc: false, max_rank: 20)
    end
  end

  test 'get_newcomers_default_params_test' do
    RedshiftBaseMock.set_result("SELECT * FROM daily_newcomers  WHERE ranking_type IN ('27','topselling_free','30','topselling_paid','38','topgrossing') AND created_at > '#{14.days.ago.strftime("%Y-%m-%d")}' AND rank < 500 ORDER BY created_at DESC OFFSET 0 LIMIT 20", @mock_newcomer_apps_response)
    RedshiftBaseMock.set_result("SELECT COUNT(app_identifier) FROM daily_newcomers  WHERE ranking_type IN ('27','topselling_free','30','topselling_paid','38','topgrossing') AND created_at > '#{14.days.ago.strftime("%Y-%m-%d")}' AND rank < 500", @mock_count_response)
    
    result = @accessor.get_newcomers

    assert_equal result["total"], 10
    assert_equal result["apps"][0]["app_identifier"], "com.terran.marine"
    assert_equal result["apps"][0]["rank"], 3
    assert_equal result["apps"][1]["app_identifier"], "123456"
    assert_equal result["apps"][1]["rank"], 100
    assert_equal result["apps"][2]["app_identifier"], "com.zerg.overlord"
    assert_equal result["apps"][2]["rank"], 2020
  end

  test 'get_newcomers_single_params_test' do
    RedshiftBaseMock.set_result("SELECT * FROM daily_newcomers  WHERE platform IN ('ios') AND ranking_type IN ('27','30','38') AND created_at > '#{14.days.ago.strftime("%Y-%m-%d")}' AND rank < 500 ORDER BY created_at DESC OFFSET 0 LIMIT 20", @mock_newcomer_apps_response)
    RedshiftBaseMock.set_result("SELECT COUNT(app_identifier) FROM daily_newcomers  WHERE platform IN ('ios') AND ranking_type IN ('27','30','38') AND created_at > '#{14.days.ago.strftime("%Y-%m-%d")}' AND rank < 500", @mock_count_response)
    
    result = @accessor.get_newcomers(platforms:["ios"])

    assert_equal result["total"], 10
    assert_equal result["apps"][0]["app_identifier"], "com.terran.marine"
    assert_equal result["apps"][0]["rank"], 3
    assert_equal result["apps"][1]["app_identifier"], "123456"
    assert_equal result["apps"][1]["rank"], 100
    assert_equal result["apps"][2]["app_identifier"], "com.zerg.overlord"
    assert_equal result["apps"][2]["rank"], 2020
  end

  test 'get_newcomers_multiple_params_test' do
    RedshiftBaseMock.set_result("SELECT * FROM daily_newcomers  WHERE ranking_type IN ('27','topselling_free') AND created_at > '#{5.days.ago.strftime("%Y-%m-%d")}' AND rank < 50 ORDER BY created_at DESC OFFSET 580 LIMIT 20", @mock_newcomer_apps_response)
    RedshiftBaseMock.set_result("SELECT COUNT(app_identifier) FROM daily_newcomers  WHERE ranking_type IN ('27','topselling_free') AND created_at > '#{5.days.ago.strftime("%Y-%m-%d")}' AND rank < 50", @mock_count_response)
    
    result = @accessor.get_newcomers(rank_types:["free"], lookback_time: 5.days.ago, max_rank: 50, page_num: 30)

    assert_equal result["total"], 10
    assert_equal result["apps"][0]["app_identifier"], "com.terran.marine"
    assert_equal result["apps"][0]["rank"], 3
    assert_equal result["apps"][1]["app_identifier"], "123456"
    assert_equal result["apps"][1]["rank"], 100
    assert_equal result["apps"][2]["app_identifier"], "com.zerg.overlord"
    assert_equal result["apps"][2]["rank"], 2020
  end

  test 'get_newcomers_validate_params_test' do
    assert_raise do
      @accessor.get_newcomers(platforms:["Zerg"], lookback_time: 5.days.ago, max_rank: 50, page_num: 30)
    end

    assert_raise do
      @accessor.get_newcomers(rank_types:["2v2 Noobs Only"], lookback_time: 5.days.ago, max_rank: 50, page_num: 30)
    end
  end

  test 'get_raw_charts_test' do
    RedshiftBaseMock.set_result("SELECT * FROM daily_raw_charts WHERE platform='android' AND country='KR' AND category='SPORTS' AND ranking_type='topgrossing' ORDER BY rank ASC OFFSET 20 LIMIT 10", @mock_get_chart_response)
    RedshiftBaseMock.set_result("SELECT count(app_identifier) FROM daily_raw_charts WHERE platform='android' AND country='KR' AND category='SPORTS' AND ranking_type='topgrossing'", @mock_count_response)
    
    result = @accessor.get_chart(platform: "android", country: "KR", category: "SPORTS", rank_type: "grossing", size: 10, page_num: 3)

    assert_equal result["total"], 10
    assert_equal result["apps"][0]["app_identifier"], "com.zerg.hydralisk"
    assert_equal result["apps"][0]["rank"], 1
    assert_equal result["apps"][1]["app_identifier"], "com.protoss.archon"
    assert_equal result["apps"][1]["rank"], 2
  end

  test 'get_raw_charts_validate_params_test' do
    assert_raise do
      @accessor.get_chart(platform: "Protoss", country: "KR", category: "SPORTS", rank_type: "grossing", size: 10, page_num: 3)      
    end

    assert_raise do
      @accessor.get_chart(platform: "ios", country: "2v2 Noobs Only", category: "SPORTS", rank_type: "grossing", size: 10, page_num: 3)      
    end
  end

end
