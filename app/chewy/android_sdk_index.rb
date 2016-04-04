class AndroidSdkIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      defaultAnalyzer: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      }
    }
  }

  define_type AndroidSdk.display_sdks.where(flagged: false) do
    field :name
  end

end