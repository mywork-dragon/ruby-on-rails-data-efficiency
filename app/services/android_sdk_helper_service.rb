class AndroidSdkHelperService

  class << self

    def freq(name)
      {sdk_package_freq: sdk_package_freq(name), dll_freq: dll_freq(name), js_tag_freq: js_tag_freq(name)}
    end

    def sdk_package_freq(name)
      freq_hash(SdkPackage, SdkPackagesApkSnapshot, :sdk_package_id, :package, name)
    end

    def dll_freq(name)
      freq_hash(SdkDll, ApkSnapshotsSdkDll, :sdk_dll_id, :name, name)
    end

    def js_tag_freq(name)
      freq_hash(SdkJsTag, ApkSnapshotsSdkJsTag, :sdk_js_tag_id, :name, name)
    end

    def like_query(the_class, name_column, name)
      the_class.where("#{name_column.to_s} LIKE ?", "%#{name}%")
    end

    def freq_hash(item_class, join_table_class, join_table_foreign_key, name_column, name)
      items = like_query(item_class, name_column, name)

      ret = {}
      items.map do |item|
        ret[item] = {id: item.id, name_column => item.send(name_column), count: join_table_class.where(join_table_foreign_key => item.id).count}
      end.sort_by{ |x| -x[:count]}
    end

  end

end