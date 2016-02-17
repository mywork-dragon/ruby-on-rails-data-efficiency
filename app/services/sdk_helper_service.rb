class SdkHelperService

  class << self

    def dll_freqs(name)
      freq_hash(like_query(SdkDll, name), ApkSnapshotsSdkDll, :sdk_dll_id, :name)
    end

    def like_query(the_class, name)
      the_class.where('name LIKE ?', "%#{name}%")
    end

    def freq_hash(items, join_table_class, join_table_foreign_key, name_column)
      ret = {}
      items.map do |item|
        ret[item] = {id: item.id, name_column => item.send(name_column), count: join_table_class.where(join_table_foreign_key => item.id).count}
      end.sort_by{ |x| -x[:count]}
    end

  end

end