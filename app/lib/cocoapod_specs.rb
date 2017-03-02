class CocoapodSpecs

  def pod(pod_name, version: nil)

    if version.nil?
      versions = GithubApi.contents(
        'Cocoapods/Specs',
        File.join('Specs', pod_specs_prefix(pod_name), pod_name)
      )

      version = versions.sort_by do |hash|
        hash['name'].split('.').map(&:to_i)
      end.last['name']
    end

    path = File.join('Specs', pod_specs_prefix(pod_name), pod_name, version, "#{pod_name}.podspec.json")

    x = GithubApi.contents('Cocoapods/Specs', path)
    JSON.parse(GithubApi.contents('Cocoapods/Specs', path))
  end

  # http://blog.cocoapods.org/Sharding/
  # http://www.rubydoc.info/gems/cocoapods-core/Pod%2FSource%2FMetadata:path_fragment
  def pod_specs_prefix(pod_name)
    hashed = Digest::MD5.hexdigest(pod_name)
    # by default, uses [1, 1, 1] prefix length
    prefixes = [1, 1, 1].map do |length|
        hashed.slice!(0, length)
    end
    File.join(prefixes)
  end
end
