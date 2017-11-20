class RedshiftDbConnection < DbConnection

  def initialize(db_config: Rails.application.config.redshift_db_config[Rails.env.to_s])
    super(db_config: db_config, default_options: {:cache_prefix => "varys-redshift-cache"})
  end

end
