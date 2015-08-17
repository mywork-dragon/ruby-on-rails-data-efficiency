class AppsIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      title: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      }
    }
  }

  define_type IosAppSnapshot do
    field :name, :description
    # field :company_name ->(ios) {}
  end

  define_type AndroidAppSnapshot do
    field :name, :description
  end

end
