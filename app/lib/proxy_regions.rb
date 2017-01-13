module ProxyRegions
  extend ActiveSupport::Concern
  included do
    # ISO 3166-1 alpha-2
    enum region: [:US, :BR, :IN, :FR, :KR, :CN, :DE, :ID, :RU, :VN, :JP, :AU, :SG]
  end
end
