module ProxyRegions
  extend ActiveSupport::Concern
  included do
    # ISO 3166-1 alpha-2
    enum region: [
    #  0    1    2    3    4    5    6    7    8    9
      :US, :BR, :IN, :FR, :KR, :CN, :DE, :ID, :RU, :VN,

    #  10   11   12   13   14   15   16   17   18   19
      :JP, :AU, :SG, :GB, :DK, :NO, :SE, :FI, :ES, :CL,

    #  20   21   22   23   24
      :CO, :AR, :CA, :AT, :IT
    ]
  end
end
