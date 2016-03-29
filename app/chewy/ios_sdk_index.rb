class IosSdkIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      defaultAnalyzer: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      }
    }
  }

  define_type IosSdk.display_sdks.where(flagged: false) do
    field :name
  end

end