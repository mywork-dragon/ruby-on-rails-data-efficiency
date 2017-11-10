class MockCachedQuery
  def initialize(return_value: nil)
      @return_value = return_value
    end

    def fetch
      @return_value
    end
end
