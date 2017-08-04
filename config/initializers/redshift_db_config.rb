Rails.application.config.redshift_db_config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redshift_database.yml'))).result)
