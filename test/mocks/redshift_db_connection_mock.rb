class RedshiftDbConnectionMock

  def initialize
    @queries = {}
  end

  def query(sql, options={})
    @queries[sql]
  end

  def set_result(query, result)
    @queries[query] = result
  end
  
end