class RedshiftDbConnection < DbConnection
  @@pool = {}

  def initialize(db_config: Rails.application.config.redshift_db_config[Rails.env.to_s])
    super(db_config: db_config, default_options: {:cache_prefix => "varys-redshift-cache"})
  end

  class ParamsBuilder
    def initialize
      @param_number = 1
      @params = []
    end
    def add_param(value)
      @params.append(value)
      reference = "$#{@param_number}"
      @param_number += 1
      reference
    end
    def add_params(values)
      values.map {|value| add_param(value)}.join(",")
    end
    def params
      @params
    end
  end

  # Lazily establish db connection.
  def get_connection
    if @@pool[@db_config].nil?
      pool_options = {
        size: 2,
        timeout: 15,
        health_check: lambda {|conn| conn.exec("select 1")}
        }
      @@pool[@db_config] = HealthyPools.new(pool_options) do
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
