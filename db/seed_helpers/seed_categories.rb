def seed_categories
  puts "creating categories"
  disable_logging
  categories = ["Games", "Lifestyle", "Shopping", "Social", "Entertainment", "News", "Education", "Medical", "Productivity", "Music", "Photography"]
  categories.each do |cat|
    IosAppCategory.find_or_create_by(name: cat)
    AndroidAppCategory.find_or_create_by(name: cat)
  end
ensure
  puts "Created IosCategories: #{IosAppCategory.count}"
  puts "Created AndroidCategories: #{AndroidAppCategory.count}"
  enable_logging
end
