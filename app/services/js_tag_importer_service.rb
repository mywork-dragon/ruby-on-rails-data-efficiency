class JsTagImporterService

  class << self

    def run(file_path)
      a = File.open(file_path).read
      config = JSON.load(a)

      apps_android = {}
      apps_ios = {}
      names_ids = config["apps"].map do |key, value|
        {name: value["name"], id: key.to_s}
      end

      # take second one, so reverse twice
      names_ids = names_ids.reverse.uniq{ |x| x[:name].downcase }.reverse

      names_ids.each do |name_id|
        android_sdk = AndroidSdk.create(
          name: name_id[:name] + " (JS)",
          kind: :js
        )
        apps_android[name_id[:id]] = android_sdk.id

        ios_sdk = IosSdk.create(
          name: name_id[:name] + " (JS)",
          kind: :js
        )
        apps_ios[name_id[:id]] = ios_sdk.id
      end

      # this is the hash from bug_id to our internal service_id
      bug_hash_android = {}
      bug_hash_ios = {}
      config["bugs"].each do |key, value|
        bug_hash_android[key] = apps_android[value["aid"].to_s]
        bug_hash_ios[key] = apps_ios[value["aid"].to_s]
      end

      config["patterns"]["regex"].each do |key, value|
        JsTagRegex.create!(
            android_sdk_id: bug_hash_android[key],
            ios_sdk_id: bug_hash_ios[key],
            regex: value
          )
      end

      config["patterns"]["path"].each do |key, value|
        JsTagRegex.create!(
          android_sdk_id: bug_hash_android[value.to_s],
          ios_sdk_id: bug_hash_ios[value.to_s],
          regex: Regexp.escape(key)
        )
      end

      recursive_get_hosts(config["patterns"]["host"], "", bug_hash_android, bug_hash_ios)

      recursive_get_host_path(config["patterns"]["host_path"], "", bug_hash_android, bug_hash_ios)
    end


    def recursive_get_hosts(hash, current_append, bug_hash_android, bug_hash_ios)
      hash.each do |key, value|
        # we hit the bottom of the recursive loop
        if key == "$"
          JsTagRegex.create!(
            android_sdk_id: bug_hash_android[value.to_s],
            ios_sdk_id: bug_hash_ios[value.to_s],
            regex: Regexp.escape(current_append[1..-1])
          )
        else
          recursive_get_hosts(value, ".#{key}"+current_append, bug_hash_android, bug_hash_ios)
        end
      end
    end


    def recursive_get_host_path(hash, current_append, bug_hash_android, bug_hash_ios)
      hash.each do |key, value|
        # we hit the bottom of the recursive loop
        if key == "$"
          value.each do |path_value|
            path_string = path_value["path"]
            host_with_path_string = current_append[1..-1] + "/" + path_string
            JsTagRegex.create!(
              android_sdk_id: bug_hash_android[path_value["id"].to_s],
              ios_sdk_id: bug_hash_ios[path_value["id"].to_s],
              regex: Regexp.escape(host_with_path_string)
            )
          end
        else
          recursive_get_host_path(value, ".#{key}"+current_append, bug_hash_android, bug_hash_ios)
        end
      end
    end

  end

end