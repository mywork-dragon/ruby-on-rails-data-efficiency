class DomainDataHotStore < HotStore

  def initialize()
    super

    @key_set = "domain_data_keys"
  end

  def write(domain_datum, async: false)
    domain = domain_datum["domain"]
    return if domain.nil?

    write_entry(nil, nil, nil, domain_datum, override_key: domain_data_key(domain), async: async)
  end

  def read(domain)
    read_entry(nil, nil, nil, override_key: domain_data_key(domain))
  end

  def delete(domain)
    delete_entry(nil, nil, nil, override_key: domain_data_key(domain))
  end

private
  
  def domain_data_key(domain)
    "dd:#{domain}"
  end

end
