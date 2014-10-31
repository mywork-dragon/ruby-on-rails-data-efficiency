class RestforceService

  def client
    client = Restforce.new :username => 'jason@mightysignal.com',
      :password       => 'knKnsjnsansaf23764KSJANFssas',
      :security_token => 'vZyFBHo9FHpqRWjDUhsIrjzdM',
      :client_id      => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
      :client_secret  => '3173051852013251576'
  end
  
  class << self
  
    def client
      RestforceService.new.client
    end
    
  end


end