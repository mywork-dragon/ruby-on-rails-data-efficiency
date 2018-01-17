module EncryptedAttributes

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def kms_encrypt(key_id, value)
      self.class.kms_encrypt(key_id, value)
    end

    def kms_decrypt(value)
      self.class.kms_decrypt(value)
    end
  end

  module ClassMethods

    def encrypt_attribute(attribute_name, kms_key)
      self.instance_eval do 
        define_method("#{attribute_name.to_s}=".to_sym) do |attribute_value|
          write_attribute(attribute_name, Base64.encode64(kms_encrypt(kms_key, JSON.dump(attribute_value))))
        end
        define_method(attribute_name) do 
          if read_attribute(attribute_name)
            JSON.load(kms_decrypt(Base64.decode64(read_attribute(attribute_name))))
          end
        end
      end
    end

    def disable_attribute_encryption(attribute_name)
      self.instance_eval do
        remove_method "#{attribute_name.to_s}=".to_sym
        remove_method attribute_name
      end
    end

    def kms_encrypt(key_id, value)
      resp = Aws::KMS::Client.new.encrypt({
            key_id: key_id, 
            plaintext: value
          }).ciphertext_blob
    end

    def kms_decrypt(value)
      resp = Aws::KMS::Client.new.decrypt({
        ciphertext_blob: value
      }).plaintext
    end

  end
end
