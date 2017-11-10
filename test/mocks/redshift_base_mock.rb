class RedshiftBaseMock
  class << self
    @@queries = {}

    def query(sql, options={})
      @@queries[sql]
    end

    def set_result(query, result)
      @@queries[query] = result
    end

  end
end
