class GoogleAccountDummyWorker

    include Sidekiq::Worker

    sidekiq_options queue: :sdk

    def perform
      puts "Begin perform for jid #{self.jid}."

      tm = nil

      t0 = Benchmark.measure do
        TestModel.transaction do 
          tm = TestModel.where(string0: 'false').sample
          tm.string0 = 'true'
          tm.save!
        end
      end.real

      puts "Account choose time: #{t0}"

      sleep rand(20..45) # pretend to do rest of job

      t1 = Benchmark.measure do
        TestModel.transaction do 
          tm.string0 = 'false'
          tm.save!
        end
      end.real

      puts "Account reset time: #{t1}"

      puts "End perform for jid #{self.jid}."
    end

    class << self 

      def seed
        300.times do |n|
          TestModel.create!(string0: 'false')
        end
      end

      def reset
        TestModel.find_each do |tm|
          tm.string0 = 'false'
          tm.save!
        end
      end

      def run(n = 1000)
        n.times do
          GoogleAccountDummyWorker.perform_async
        end
      end

    end


end