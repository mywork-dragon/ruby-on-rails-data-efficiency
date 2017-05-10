module MobileApp
  def ad_attribution_sdks
    tag = Tag.where(id: 24).first
    return [] unless tag
   
    attribution_sdk_ids = tag.ios_sdks.pluck(:id)
    self.installed_sdks.select{|sdk| attribution_sdk_ids.include?(sdk["id"])}
  end
end
