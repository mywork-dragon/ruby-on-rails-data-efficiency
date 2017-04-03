module DeveloperContactWebsites
  def possible_contact_domains
    websites = self.valid_websites.map(&:url)
    websites << self.try(:ios_apps).try(:first).try(:support_url) if self.try(:ios_apps).try(:first).try(:support_url)
    websites << self.try(:android_apps).try(:first).try(:support_url) if self.try(:android_apps).try(:first).try(:support_url)
    domains = websites.map { |url| UrlHelper.url_with_domain_only(url) }
    Set.new(domains.select {|x| x.present?})
  end
end
