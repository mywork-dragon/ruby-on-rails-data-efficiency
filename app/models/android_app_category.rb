class AndroidAppCategory < ActiveRecord::Base

  has_many :android_app_categories_snapshots
  has_many :android_app_snapshots, through: :android_app_categories_snapshots

  def as_json(_options = {})
    {
      name: display_name,
      id: category_id,
      platform: 'android',
      parent: parent_category
    }
  end

  def parent_category_prefixes
    {'GAME_' => 'Games', 'FAMILY_' => 'Family'}
  end

  def parent_category
    # Infer the parent category from the category ID.
    parent_category_prefixes.each do |prefix, display_name|
        if (!category_id.nil?) && category_id.starts_with?(prefix)
            return {name: display_name, id: prefix.tr('_', '')}
        end
    end
    nil
  end

  def display_name
    parent = parent_category
    if !parent.nil?
        return "#{name} (#{parent[:name]})"
    else
        return name
    end
  end
end
