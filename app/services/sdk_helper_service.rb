class SdkHelperService

  class << self

    def dll_freqs(name)
      freq_hash(like_query(SdkDll, name), ApkSnapshotsSdkDll, :sdk_dll_id)
    end

    def like_query(the_class, name)
      the_class.where('name LIKE ?', "%#{name}%")
    end

    def freq_hash(items, join_table_class, join_table_foreign_key)
      ret = {}
      items.each do |item|
        ret[item] = {item => join_table_class.where(join_table_foreign_key => item.id).count}
      end
      # ret.sort_by{ |k, v| v}
      ret
    end

  end

end