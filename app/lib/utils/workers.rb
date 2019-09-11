module Utils
  module Workers
    def designate(clazz, *params)
      ENV['JOBS_PERFORM_INLINE'] ? clazz.new.perform(*params) : clazz.perform_async(*params)
    end
  end
end
