class DbConnection

  def initialize(db_config:, default_options: {})
    @db_config = db_config
    @default_options = default_options
    @connection = nil
  end

  # Lazily establish db connection.
  def exec
    raise "Abstract method!"
  end

  def query(sql, options={})
    CachedQuery.new(sql, self, @default_options.merge(options))
  end

  def sanitize_sql_statement(array)
    ActiveRecord::Base::sanitize_sql_array(array)
  end  

end
