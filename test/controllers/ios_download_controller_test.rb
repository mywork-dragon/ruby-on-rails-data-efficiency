require 'test_helper'
require 'action_controller'
require 'json'

class IosDownloadControllerTest < ActionController::TestCase
  
  def setup
    @ipa_snapshot_1 = IpaSnapshot.create!()
    @classdump_1 = ClassDump.create!(:ipa_snapshot_id => @ipa_snapshot_1.id)
  end

  def test_set_ipa_snapshot_status
    @controller.stub :authenticate_request, nil do
      @controller.stub :authenticate_admin_account, nil do
        response = put(:set_ipa_snapshot_status, "{\"download_status\":\"cleaning\",\"scan_status\":\"arch_issue\",\"success\":\"true\"}", :varys_cd_id => @classdump_1.id)
        data = JSON.parse(response.body)
        assert_equal 200, response.status

        assert_equal "cleaning", IpaSnapshot.find(@ipa_snapshot_1.id).download_status
        assert_equal "arch_issue", IpaSnapshot.find(@ipa_snapshot_1.id).scan_status
        assert IpaSnapshot.find(@ipa_snapshot_1.id).success
      end
    end
  end

end
