require 'test_helper'

class AppleEpfTest < ActiveSupport::TestCase

  def setup
    @epf_response = MiniTest::Mock.new
    @epf_response.expect(:code, 200)
    @epf_response.expect(:body, open(File.join(Rails.root, 'test', 'data', 'epf_wo_incremental.html')).read)
  end

  test 'Presents current urls even without incremental'  do
    AppleEpf.stub :get, @epf_response do
      res = AppleEpf.current_urls
      assert res[:itunes]
      assert res[:match]
      assert res[:popularity]
      assert res[:pricing]
      assert res[:incremental].nil?
    end
  end

end
