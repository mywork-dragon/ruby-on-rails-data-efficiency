# DomainLinker
# Provides an interface for linking domains to publishers.

class DomainLinker
  @@hotstore = nil
  def initialize()
    @downloaded = false
    @domain_to_publishers = Hash.new {[]}
    if @@hotstore.nil?
      @@hotstore = PublisherHotStore.new
    end
  end

  def download!
    domain_pub_url = 'https://feeds.mightysignal.com/v1/internal/domain-publisher-relationships/latest/domain-publisher-relationships.gz'
    open(domain_pub_url, "JWT" => ENV['MS_FEEDS_TOKEN']) do |f_remote|
      csv = CSV.new(Zlib::GzipReader.new(f_remote).read)
      csv.each do |row|
        @domain_to_publishers[row[0]] = @domain_to_publishers[row[0]] + [row[1]]
      end
    end
    @downloaded = true
  end

  def domain_to_publisher(domain)
    if !@downloaded
      download!
    end
    return @domain_to_publishers[domain].map do |publisher_id|
      platform, publisher_id = publisher_id.split '-'
      "#{platform}_developer".classify.constantize.find(publisher_id)
    end
  end

  def publisher_to_domains(platform, publisher_id)
    @@hotstore.read(platform, publisher_id)['domains'] || []
  end

end
