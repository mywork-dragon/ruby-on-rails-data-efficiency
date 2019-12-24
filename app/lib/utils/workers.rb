module Utils
  module Workers
    def delegate_perform(clazz, *params)
      perform_inline = ActiveRecord::Type::Boolean.new.type_cast_from_database(ENV['JOBS_PERFORM_INLINE'])
      perform_inline ? clazz.new.perform(*params) : clazz.perform_async(*params)
    end
  end
end
