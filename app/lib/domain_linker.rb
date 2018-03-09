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

end
