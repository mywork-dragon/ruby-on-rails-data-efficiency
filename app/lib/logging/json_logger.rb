require "json/add/exception"

class JsonLogger

  def initialize(options={})
    @logger = Logger.new(options[:filename] || STDOUT)
    @included_keys = options[:included_keys] || {}
    setup
  end

  def setup
    @logger.formatter = proc do |severity, datetime, progname, msg|
      line = JSON.generate(
        { severity: severity, datetime: datetime, progname: progname }
        .merge(@included_keys).merge(msg)
      )
      "#{line}\n"
    end
  end

  def add_key(k,v)
    @included_keys[k] = v
  end

  def log(msg, level=Logger::INFO)
    @logger.add(level, { message: msg })
  end

  def log_exc(e, level=Logger::ERROR)
    @logger.add(level, e.as_json)
  end

  def log_json(json, level=Logger::INFO)
    @logger.add(level, json)
  end
end
