module SalesforceMarketingService

  class << self
    def run
      jm = JobMarker.new
      jm.started

      ee = EmailExporter.new
      emails = ee.get_emails
      domains = emails.map{ |e| EmailToDomainConverter.convert(e) }

      rw = RedisWriter.new
      rw.clear
      rw.write(domains)
    
      jm.finished

      true
    end 
  end


  class EmailExporter
    
    attr_reader :client, :bulk_client

    def initialize
      host = 'login.salesforce.com'

      @account = get_account

      client_id = '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9'

      @client ||= Restforce.new(
        oauth_token: @account.salesforce_token,
        refresh_token: @account.salesforce_refresh_token,
        authentication_callback: method(:refresh_token),
        instance_url: @account.salesforce_instance_url,
        client_id: client_id,
        client_secret: ENV['SALESFORCE_AUTH_CLIENT_SECRET'],
        api_version: '39.0',
        host: host
    )

    @client.authenticate!

    # @bulk_client = SalesforceBulkApi::Api.new(@client)
    # @bulk_client.connection.set_status_throttle(30)
    end

    def get_account
      Rails.env.production? ? Account.find(215) : Account.find_by_name('MightySignal')
    end

    def refresh_token(response)
      @account.update_attributes(salesforce_token: response["access_token"])
    end

    def get_emails
       @client.query("select email from Lead").map(&:Email)
    end

    class << self

      def seed_local_account
        account = Account.find_by_name('MightySignal')
        account.salesforce_uid = ENV['MARKETING_API_SALESFORCE_UID']
        account.salesforce_token = ENV['MARKETING_API_SALESFORCE_TOKEN']
        account.salesforce_refresh_token = ENV['MARKETING_API_SALESFORCE_REFRESH_TOKEN']
        account.salesforce_instance_url = ENV['MARKETING_API_SALESFORCE_INSTANCE_URL']
        account.save!
      end

    end

  end

  class EmailToDomainConverter

    def convert(email)
      Mail::Address.new(email).domain
    end

    class << self

      def convert(email)
        self.new.convert(email)
      end
      
    end

  end


  class RedisWriter

    attr_reader :redis, :list

    def initialize
      @redis = Redis.new(host: ENV['REDIS_DISCOVERY_URL'], port: ENV['REDIS_DISCOVERY_PORT'])
      @set = 'sfdc_email_export'
    end

    def write(values)
      @redis.pipelined do
        values.each do |value|
          @redis.sadd(@set, value)
        end
      end
    end

    def clear
      @redis.del(@set)
    end

    def length
      @redis.scard(@set)
    end

    class << self

      def test_write
        values = []
        1e3.to_i.times do 
          values << {'a' => SecureRandom.hex.to_s, 'b' => SecureRandom.hex.to_s}.to_json
        end

        rw = RedisWriter.new
        rw.write(values)
      end

    end

  end

  class JobMarker

    def initialize
      @redis = Redis.new(host: ENV['REDIS_DISCOVERY_URL'], port: ENV['REDIS_DISCOVERY_PORT'])
      @key = 'sfdc_email_export_status'
    end

    def started
      @redis.set(@key, 'running')
    end

    def finished
      @redis.set(@key, 'finished')
    end

  end 

end