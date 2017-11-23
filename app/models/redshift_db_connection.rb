class RedshiftDbConnection < DbConnection
  @@pool = {}

  def initialize(db_config: Rails.application.config.redshift_db_config[Rails.env.to_s])
    super(db_config: db_config, default_options: {:cache_prefix => "varys-redshift-cache"})
  end

  # Lazily establish db connection.
  def get_connection
    if @@pool[@db_config].nil?
      @@pool[@db_config] = ConnectionPool.new(size: 2, timeout: 15) do
        connection = PG.connect(
           dbname: @db_config['database'],
           port: @db_config['port'],
           user: @db_config['username'],
           password: @db_config['password'],
           host: @db_config['host']
          )
        connection.type_map_for_results = PG::BasicTypeMapForResults.new connection
        connection
      end

    end
    @@pool[@db_config].with do |conn|
      yield conn
    end
  end

end
