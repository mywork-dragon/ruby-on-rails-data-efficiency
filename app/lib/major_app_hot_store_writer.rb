

class MajorAppHotStoreWriter

  def initialize()
    @hs = AppHotStore.new
    @major_app_identifiers = Set.new
    @domain_linker = DomainLinker.new
  end

  def _write_app(app)
    if ! @major_app_identifiers.include? app.app_identifier
      @hs.write_major_app(app.id, app.app_identifier, app.platform, major_app: true)
      @major_app_identifiers.add(app.app_identifier)
    end
  end

  def write_ios_major_charts
    (
      RankingsAccessor.new.get_chart(platform: 'ios', country: 'US', category: '36', rank_type: 'free', size: 200)['apps'] +
      RankingsAccessor.new.get_chart(platform: 'ios', country: 'US', category: '36', rank_type: 'grossing', size: 200)['apps']
    ).map do |app|
      if ! @major_app_identifiers.include? app['app_identifier']
        _write_app(IosApp.find_by_app_identifier(app['app_identifier']))
      end
    end
  end

  def write_android_major_charts
    (
      RankingsAccessor.new.get_chart(platform: 'android', country: 'US', category: 'OVERALL', rank_type: 'free', size: 200)['apps'] +
      RankingsAccessor.new.get_chart(platform: 'android', country: 'US', category: 'OVERALL', rank_type: 'grossing', size: 200)['apps']
    ).map do |app|
      if ! @major_app_identifiers.include? app['app_identifier']
        _write_app(AndroidApp.find_by_app_identifier(app['app_identifier']))
      end
    end
  end


  def write_fortune_1000
    # nils prevent returning which can cause OOM
    DomainDatum.where.not(:fortune_1000_rank => nil).uniq.map do |dd|
      @domain_linker.domain_to_publisher(dd.domain).map do |publisher|
        publisher.apps.map do |app|
          _write_app(app)
        end
        nil
      end
      nil
    end
  end


  def write_major_app_tag
    (
      Tag.find_by(name: "Major App").android_apps +
      Tag.find_by(name: "Major App").ios_apps
    ).each do |app|
      _write_app(app)
    end
  end

  def write_major_publisher_tag
    (
    Tag.find_by(name: "Major Publisher").android_developers +
    Tag.find_by(name: "Major Publisher").ios_developers
    ).each do |dev|
      dev.apps.map do |app|
        _write_app(app)
      end
    end
  end

end
