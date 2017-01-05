require 'test_helper'

class ProxyPartyRegionalTest < Minitest::Test
  include ProxyParty

  def selecting_a_regional_proxy
    m1 = MicroProxy.create!(:active=>true, :public_ip => '123',
      :private_ip =>'123', :purpose => :ios)
    m2 = MicroProxy.create!(:active=>true, :public_ip => '456',
      :private_ip =>'456', :purpose => :region, :region => :US)
    s1 = self.class.select_proxy(proxy_type: :android_classification, region: nil)
    s2 = self.class.select_proxy(proxy_type: :android_classification, region: :US)

    assert_equal m1.private_ip, s1[:ip]
    assert_equal m2.private_ip, s2[:ip]
  end

  class TestClass
    include ProxyParty
    def make_request
      regions = []
      begin
      self.class.try_all_regions do |region|
        regions += [region]
        raise ProxyParty::UnsupportedRegion
      end
      rescue ProxyParty::AllRegionsFailed
      end
      regions
    end
  end

  def proxies_are_tried_in_the_correct_order
    MicroProxy.create!(:active=>true, :public_ip => '123', :private_ip =>'123', :purpose => :ios)
    MicroProxy.create!(:active=>true, :public_ip => '123', :private_ip =>'123', :purpose => :region, :region => :US)
    MicroProxy.create!(:active=>true, :public_ip => '123', :private_ip =>'123', :purpose => :region, :region => :BR)

    obj = TestClass.new
    regions = obj.make_request
    # The general proxies come first.
    assert_equal nil, regions[0]
    # All regions are tried.
    assert_equal [nil, "BR", "US"], regions.sort_by {|x| x.to_s}
  end

end
