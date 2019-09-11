module DummyClassHelpers

  def dummy_class(name, &block)
    let(name.to_s.underscore) do
      klass = Class.new(&block)

      self.class.const_set name.to_s.classify, klass
    end
  end

end
