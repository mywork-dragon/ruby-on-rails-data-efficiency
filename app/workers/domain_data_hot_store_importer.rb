class DomainDataHotStoreImporter

  def initialize
    @hot_store = DomainDataHotStore.new
  end
  
  def import
    DomainDatum.find_each(batch_size: 1000) do |dd|
      @hot_store.write(dd.as_json)
    end
  end

end
