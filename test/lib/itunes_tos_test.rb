require 'test_helper'

class ItunesTosTest < Minitest::Test
  def setup
    @html = open(File.join(Rails.root, 'test', 'data', 'itunes_tos_us.html')).read
  end

  def test_accepts_valid_date_text
    ItunesTos.validate_date_text('Last Updated: September 13, 2016')
  end

  def test_invalidates_badly_formatted_date_text
    assert_raises(ItunesTos::InvalidHTML) { ItunesTos.validate_date_text('too short') }
    assert_raises(ItunesTos::InvalidHTML) { ItunesTos.validate_date_text('Missing colon - September 13, 2016') }
  end

  def test_extracts_date_text_from_html
    date_text = ItunesTos.last_updated_text(@html)
    assert date_text.match(/Last Updated/)
  end

  def test_extracts_dates
    date_text = 'Last Updated: September 13, 2016'

    GoogleTranslateApi.stub :translate, 'September 13, 2016' do
      assert_equal Date.parse('September 13, 2016'), ItunesTos.extract_date('Last Updated: September 13, 2016')
      assert_equal Date.parse('September 13, 2016'), ItunesTos.extract_date('Última Atualização: 13 de setembro de 2016')
    end
  end

  def test_returns_date_for_app_store
    httparty_response = MiniTest::Mock.new
    httparty_response.expect(:body, @html)

    app_store = AppStore.create!(name: 'United States', tos_url_path: '/us/terms.html')
    ItunesTos.stub :get, httparty_response do
      GoogleTranslateApi.stub :translate, 'September 13, 2016' do
        assert_equal Date.parse('September 13, 2016'), ItunesTos.itunes_updated_date(app_store_id: app_store.id)
      end
    end

    httparty_response.verify
  end
end
