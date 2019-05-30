# DomainLinker
# Provides an interface for linking domains to publishers.

class DomainLinker
  @@hotstore = nil
  @@dd_hotstore = nil  

  def initialize()
    @downloaded = false
    @domain_to_publishers = Hash.new {[]}
    if @@hotstore.nil?
      @@hotstore = PublisherHotStore.new
    end
    if @@dd_hotstore.nil?
      @@dd_hotstore = DomainDataHotStore.new
    end
    @top_domains = File.read('top-1m.csv').split("\n").map{ |i| i.split(",").last }
  end

  def domain_to_publisher(domain)
    record = @@dd_hotstore.read(domain)

    record.fetch('publishers', []).map do |publisher|
      "#{publisher['platform']}_developer".classify.constantize.find(publisher['publisher_id'])
    end
  end

  def publisher_to_domains(platform, publisher_id)
    @@hotstore.read(platform, publisher_id)['domains'] || []
  end
  
  def get_best_publisher(domain, platform)
    publisher_id = handle_major_publishers(domain, platform)
    return publisher_id if publisher_id > 0
    
    domain_co = domain.split('.').first
    developer_ids = platform == 'ios' ? Website.where(domain: domain).map{ |w| w.ios_developer_ids }.flatten.uniq : Website.where(domain: domain).map{ |w| w.android_developer_ids }.flatten.uniq
    devs = []
    developer_ids.each do |id|
      h = Hash.new
      developer = platform == 'ios' ? IosDeveloper.find(id) : AndroidDeveloper.find(id)
      h['id'] = id
      h['company'] = clean(developer.name)
      h['company_length'] = h['company'].size
      h['domain'] = domain
      h['rank'] = domains.index(domain) || 1000000
      h['test'] = inclusion_test(domain_co, h['company'])
      devs << h
    end
    #find devs where test is true and pick the lowest rank and then shortest company name
    winner = devs.select{ |d| d['test'] == true }.sort_by{ |v| [v['rank'],v['company_length']] }.first
    if winner.present?
      developer = platform == 'ios' ? IosDeveloper.find(winner['id']) : AndroidDeveloper.find(winner['id'])
      publisher_id = developer.id
    end
    publisher_id
  rescue
    0
  end
  
  # should prefer .com
  # handle acronym company names
  # incorporate page scraper
  def get_best_domain(publisher)
    domains = publisher.website_urls.map{ |w| UrlHelper.url_with_domain_only(w) }.uniq.compact
    sites = []
    domains.each do |domain|
      h = Hash.new
      h['domain'] = domain
      h['company'] = clean(publisher.name)
      h['company_length'] = h['company'].size
      h['rank'] = @top_domains.index(domain) || 1000000
      h['test'] = inclusion_test(domain.split(".").first, h['company'])
      sites << h
    end
    winner = sites.select{ |d| d['test'] == true }.sort_by{ |v| [v['rank'],v['company_length']] }.first
    winner.nil? ? nil : winner['domain']
  end
  
  private
  
  def clean(string)
    clean_company(string).to_s.downcase.gsub(/[\.\s]/, '')
  end

  def inclusion_test(domain_co, publisher_name)
    sort = [clean(domain_co), clean(publisher_name)].sort_by(&:length)
    short = sort.first
    long = sort.last
    if short.to_s.length >= 3
      long.include? short
    else
      false
    end
  end
  
  def clean_company(company)
    company.to_s
    .gsub(/[\u0080-\u00ff]/, '') # remove non-UTF i think?
    .gsub(/\(.*\)/i, '') # remove parentheses and all content between
    .gsub(/,?\s+(pty ltd|pte ltd|ltd|llc|l.l.c|inc|lp|llp|corporation|associates|holdings|corporate)(\.|\s)?/i, '') # remove common company endings
    .gsub(/[^0-9a-z:.\/\s-]/i, '')
    .gsub('...', '')
    .gsub(/\.+/i, '.')
    .sub(/^https?\:?\/\//i, '')
    .sub(/^www./i, '')
    .gsub(/\s+/, ' ')
    .gsub('--', '')
    .downcase
    .truncate(100, separator: ' ', omission: '')
    .encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    .squish
  end 
  
  def handle_major_publishers(domain, platform)
    publisher_id = false
    h = Hash.new
    h['facebook.com'] = {'ios': 37304, 'android': 55 }
    h['instagram.com'] = {'ios': 37304, 'android': 55 }
    h['google.com'] = {'ios': 6864, 'android': 928995 }
    h['gmail.com'] = {'ios': 6864, 'android': 928995 }
    h['youtube.com'] = {'ios': 6864, 'android': 928995 }
    h.dig(domain, platform.to_sym).to_i
  end

end
