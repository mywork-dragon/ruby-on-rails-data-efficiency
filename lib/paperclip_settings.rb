class PaperclipSettings
  class << self
    def obfuscation_defaults
      {
        path: ":hash.:extension",
        hash_secret: Rails.application.secrets.paperclip_hash_secret
      }
    end
  end
end