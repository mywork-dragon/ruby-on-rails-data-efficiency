class AdHerokuTransferService

  def add_workers(json_file)
    json = JSON.parse(IO.read(json_file))
    
    json.each do |worker_hash|
      aws_identifier = worker_hash['aws_worker_id']
      li "aws_identifier: #{aws_identifier}"
      
      worker = MTurkWorker.find_by_aws_identifier(aws_identifier)

      li "worker: #{worker}"
      
      if worker
        li "Worker #{aws_identifier} already in DB"
      else
        worker = MTurkWorker.create!(
          aws_identifier: aws_identifier,
          age: worker_hash['age'].to_i,
          gender: worker_hash['gender'],
          city: worker_hash['city'],
          state: worker_hash['state'],
          country: worker_hash['country'],
          iphone: worker_hash['iphone'],
          ios_version: worker_hash['ios_version'],
          heroku_identifier: worker_hash['heroku_id'].to_i
        )
        li "Created worker #{worker}"

      end
      
      li ""
      
    end
    
    
  end

  class << self
    
    def add_workers(json_file)
      self.new.add_workers(json_file)
    end
    
  end

end