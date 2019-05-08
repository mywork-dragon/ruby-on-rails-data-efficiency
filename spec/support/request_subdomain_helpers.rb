module RequestSubdomainHelpers
    # Sets host to use a given subdomain.
    def within_subdomain(subdomain)
      before { host! "#{subdomain}.example.com" }
      after  { host! "www.example.com" }
      yield
    end
  end