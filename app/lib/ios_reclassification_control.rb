class IosReclassificationControl

  class UnknownMethod < RuntimeError; end

  def initialize
    @active_methods = IosReclassificationMethod.where(active: true).pluck(:method)
  end

  def is_active?(method)
    method_id = IosReclassificationMethod.methods[method]
    raise UnknownMethod unless method_id
    @active_methods.include?(method_id)
  end
end
