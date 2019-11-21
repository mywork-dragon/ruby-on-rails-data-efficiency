module DummyClassHelpers

  def dummy_class(name, &block)
    let(name.to_s.underscore) do
      klass = Class.new(&block)
      klass_name = name.to_s.classify

      #  Here's a weird ruby bug:
      # Sometimes this error may be thrown:

      # (byebug) self.class.send(:remove_const, klass_name.to_sym)
      # *** NameError Exception: constant #<Class:0x0000000a8e8d98>::Dummy not defined
      # nil

      # But :const_defined? returns true:

      # (byebug) self.class.const_defined?(klass_name.to_sym)
      # true

      # This seems to happen when :remove_const is called twice after the constant has been set:

      # (byebug) self.class.const_set klass_name, klass
      # RSpec::ExampleGroups::AndroidScanningValidator::ValidJob::Available::Unchanged::LiveScan::Dummy

      # Calling :remove_const after that works fine w/o error the first time:

      # (byebug) self.class.send(:remove_const, klass_name.to_sym)
      # RSpec::ExampleGroups::AndroidScanningValidator::ValidJob::Available::Unchanged::LiveScan::Dummy

      # But will fail on a second call, and :const_defined? still returns true

      # (byebug) self.class.send(:remove_const, klass_name.to_sym)
      # *** NameError Exception: constant #<Class:0x0000000a8e8d98>::Dummy not defined
      # nil
      # (byebug) self.class.const_defined?(klass_name.to_sym)
      # true

      # So let's just call it every time and rescue
      # if not removing constant a # WARNING:  is shown:

      # (byebug) self.class.const_set klass_name, klass
      # RSpec::ExampleGroups::AndroidScanningValidator::ValidJob::Available::Unchanged::LiveScan::Dummy
      # (byebug) self.class.const_set klass_name, klass
      # (byebug):1: warning: already initialized constant RSpec::ExampleGroups::AndroidScanningValidator::ValidJob::Available::Unchanged::LiveScan::Dummy
      # (byebug):1: warning: previous definition of Dummy was here

      self.class.send(:remove_const, klass_name.to_sym) rescue nil

      self.class.const_set klass_name, klass
    end
  end

end
