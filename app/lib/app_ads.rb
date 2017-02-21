
module AppAds
  def self.included(base)
    base.class.class_eval do
      def ad_table(table)
        self.class_variable_set(:@@ad_table, table)
      end
    end
  end

  def ad_table
    self.class.class_variable_get(:@@ad_table).to_sym
  end

  def first_seen_ads_date
    self.send(ad_table).order(date_seen: :desc).last.try(:date_seen)
  end

  def first_seen_ads_days
    if first_seen_ads_date
      (Time.now.to_date - first_seen_ads_date.to_date).to_i
    end
  end

  def last_seen_ads_date
    latest_ad.try(:date_seen)
  end

  def last_seen_ads_days
    if last_seen_ads_date
      (Time.now.to_date - last_seen_ads_date.to_date).to_i
    end
  end

  def latest_ad
    self.send(ad_table).order(date_seen: :desc).first
  end

end
