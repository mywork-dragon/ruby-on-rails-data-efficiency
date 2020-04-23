class AppPermissionsHotstoreImporter

  attr_accessor :permissions

  def initialize(hotstore: nil, permissions: nil)
    @hotstore = hotstore || AppHotStore.new
    @permissions = permissions
  end

  def ignored_keys
    ['id']
  end

  def import_ios(id)
    app = IosApp.find(id)
    permissions = @permissions || raw_ios_permissions(id)
    @hotstore.write_attribute(id, app.app_identifier, app.platform, 'permissions', permissions)
  end

  ### internal method ##
  def raw_ios_permissions(ios_app_id)
    default = []
    snap = IosApp.find(ios_app_id).newest_ipa_snapshot
    return default unless snap.present?
    snap.class_dumps.last.plist.keys - ignored_keys
  rescue MightyAws::S3::NoSuchKey
    default
  end
end
