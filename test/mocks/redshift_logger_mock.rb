class RedshiftLoggerMock < RedshiftLogger
  attr_accessor :sent_records

  # remove actual submission
  def send!
    @sent_records ||= []
    @sent_records += @records
    clear_records
  end
end
