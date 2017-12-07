require 'test_helper'

class AccountTest < ActiveSupport::TestCase
    def setup
        @account = Account.first
    end
    test 'enable one ad network' do
        @account.enable_ad_network! 'facebook'
        assert_equal ['facebook'], @account.enabled_ad_networks
        assert @account.can_access_ad_network 'facebook'
    end

    test 'disable one ad network' do
        @account.enable_ad_network! 'facebook'
        @account.disable_ad_network! 'facebook'
        assert_equal [], @account.enabled_ad_networks
        assert_equal ['facebook'], @account.disabled_ad_networks
        assert_not @account.can_access_ad_network 'facebook'
    end

    test 'enable ad network tier' do
        tier_two_networks = AdDataPermissions::AD_DATA_TIERS['tier-2']
        @account.enable_ad_network_tier!('tier-2')
        assert_equal tier_two_networks, @account.enabled_ad_networks
    end

    test 'disable ad network tier' do
        tier_two_networks = AdDataPermissions::AD_DATA_TIERS['tier-2']
        # tier-1 is enabled by default
        @account.disable_ad_network_tier!('tier-1')
        @account.enable_ad_network_tier!('tier-2')
        @account.disable_ad_network_tier!('tier-2')
        assert_equal [], @account.enabled_ad_networks
    end

    test 'disable ad network restricts ad network tier' do
        tier_two_networks = AdDataPermissions::AD_DATA_TIERS['tier-2']
        @account.enable_ad_network_tier!('tier-2')
        @account.disable_ad_network! tier_two_networks[0]
        assert_equal tier_two_networks[1..-1], @account.enabled_ad_networks
        assert_not @account.enabled_ad_networks.include?(tier_two_networks[0])
    end

    test 'hide ad network tier' do
        tier_two_networks = AdDataPermissions::AD_DATA_TIERS['tier-2']
        @account.enable_ad_network_tier!('tier-2')
        @account.hide_ad_network!(tier_two_networks[0])
        assert_not @account.enabled_ad_networks.include? tier_two_networks[0]
        assert_not @account.visible_ad_networks.include? tier_two_networks[0]
    end

end
