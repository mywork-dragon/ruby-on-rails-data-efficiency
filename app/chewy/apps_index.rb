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
  end

end
