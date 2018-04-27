require 'test_helper'
require 'mocks/redis_mock'

class AppPermissionsHotstoreImporterTest < ActiveSupport::TestCase
  def setup
    @redis = RedisMock.new
    @hs = AppHotStore.new(redis_store: @redis)
  end

  test 'basic ios imports work' do
    permissions = ['NSLocationAlwaysOn', 'NSCopperEatingWarning']
    importer = AppPermissionsHotstoreImporter.new(hotstore: @hs, permissions: permissions)
    app = IosApp.create!(app_identifier: 897154323)
    importer.import_ios(app.id)

    attrs = @hs.read('ios', app.id)
    assert_equal app.id, attrs['id']
    assert_equal app.platform, attrs['platform']
    assert_equal app.app_identifier, attrs['app_identifier']
    assert_equal permissions, attrs['permissions']
  end
end
