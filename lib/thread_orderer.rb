# Orders all threads for a given queue
# @author Jason Lew
class ThreadOrderer

  class << self

    # Index and count
    def thread_index_count(jid:, queue:)
      self.new.thread_index_count(jid: jid, queue: queue)
    end

    # Index only
    def thread_index(jid:, queue:)
      self.new.thread_index(jid: jid, queue: queue)
    end

    # Count only
    def thread_count(jid:, queue:)
      self.new.thread_count(jid: jid, queue: queue)
    end

  end

  def thread_index_count(jid:, queue:)
    puts "jid: #{jid}, queue: #{queue}"

    my_worker = nil
    workers_for_queue = nil

    max_tries = 10
    10.times do |n|
      workers = Sidekiq::Workers.new

      workers_for_queue = workers.map do |process_id, thread_id, work|
        next if work['queue'] != queue

        my_worker = {process_id: process_id, thread_id: thread_id} if work['payload']['jid'] == jid

        {process_id: process_id, thread_id: thread_id}
      end.compact

      # break if have the worker
      break if my_worker

      raise "Could not find my_worker" if n == max_tries - 1

      sleep 1.0
    end

    workers_for_queue_sorted = workers_for_queue.sort_by{ |x| [x[:process_id], x[:thread_id]] }

    my_worker_thread_id = my_worker[:thread_id]

    index = workers_for_queue_sorted.index{ |x| x[:thread_id] == my_worker_thread_id}
    count = workers_for_queue_sorted.count

    {index: index, count: count}
  end

  def thread_index(jid:, queue:)
    thread_index_count(jid: jid, queue: queue)[:index]
  end

  def thread_count(jid:, queue:)
    thread_index_count(jid: jid, queue: queue)[:count]
  end

end