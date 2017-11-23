class RedshiftDbConnection < DbConnection

  def initialize(db_config: Rails.application.config.redshift_db_config[Rails.env.to_s])
    super(db_config: db_config, default_options: {:cache_prefix => "varys-redshift-cache"})
  end

  # Lazily establish db connection.
  def connection
    if @connection.nil?
      @connection = PG.connect(
         dbname: @db_config['database'],
         port: @db_config['port'],
         user: @db_config['username'],
         password: @db_config['password'],
         host: @db_config['host']
        )
      @connection.type_map_for_results = PG::BasicTypeMapForResults.new @connection
    end
    @connection
  end

end
