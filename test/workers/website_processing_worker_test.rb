require 'test_helper'

class WebsiteProcessingWorkerTest < ActiveSupport::TestCase

  test 'it processes websites' do
    web = Website.create!(url: 'something.com')
    web.update!(match_string: nil, domain: nil)
    WebsiteProcessingWorker.new.perform(:backfill_helpers, web.id)
    web.reload
    assert_equal 'something.com', web.domain
  end
end
