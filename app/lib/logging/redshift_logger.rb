class RedshiftLogger

  attr_accessor :firehose, :records

  def initialize(records: [], cluster: nil, database: nil, table: nil)
    @cluster = cluster || ENV['REDSHIFT_LOGGING_CLUSTER'].to_s
    @database = database || ENV['REDSHIFT_LOGGING_DATABASE'].to_s
    @table = table || ENV['REDSHIFT_LOGGING_TABLE'].to_s
    @records = records.map { |r| add_columns(r) }
    @firehose = MightyAws::Firehose.new
    self
  end

  def add(r)
    add_columns(r)
    @records << r
    self
  end

  def clear_records
    @records = []
  end

  def add_columns(r)
    r[:created_at] ||= DateTime.now.utc
    r['__cluster__'] = @cluster
    r['__database__'] = @database
    r['__table__'] = @table
    r
  end

  # max put batch record count: 500
  def send!
    res = []
    @records.each_slice(450) do |records|
      res << @firehose.batch_send(
        stream_name: Rails.application.config.redshift_firehose_stream,
        records: records.map(&:to_json)
      )
    end
    clear_records
    res
  end
end
