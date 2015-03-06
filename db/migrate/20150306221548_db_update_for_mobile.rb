class DbUpdateForMobile < ActiveRecord::Migration
  def change
    
    add_column :ios_app_releases, :name, :string
    add_column :ios_app_releases, :category, :string
    add_column :ios_app_releases, :price, :integer
    add_column :ios_app_releases, :size, :integer
    add_column :ios_app_releases, :updated, :date
    add_column :ios_app_releases, :seller_url, :string
    add_column :ios_app_releases, :support_url, :string
    add_column :ios_app_releases, :version, :string
    add_column :ios_app_releases, :released, :date
    add_column :ios_app_releases, :recommended_age, :string
    add_column :ios_app_releases, :description, :text
    add_column :ios_app_releases, :link, :string
    add_column :ios_app_releases, :app_id, :integer
    add_column :ios_app_releases, :current_version, :boolean
    add_column :ios_app_releases, :previous_release_id, :integer
    add_column :ios_app_releases, :in_app_purchases, :boolean
    add_column :ios_app_releases, :required_ios_version, :string
    add_column :ios_app_releases, :downloads, :integer
    
    add_column :android_app_releases, :name, :string
    add_column :android_app_releases, :category, :string
    add_column :android_app_releases, :price, :integer
    add_column :android_app_releases, :size, :integer
    add_column :android_app_releases, :updated, :date
    add_column :android_app_releases, :seller_url, :string
    add_column :android_app_releases, :support_url, :string
    add_column :android_app_releases, :version, :string
    add_column :android_app_releases, :released, :date
    add_column :android_app_releases, :recommended_age, :string
    add_column :android_app_releases, :description, :text
    add_column :android_app_releases, :link, :string
    add_column :android_app_releases, :app_id, :integer
    add_column :android_app_releases, :current_version, :boolean
    add_column :android_app_releases, :previous_release_id, :integer
    add_column :android_app_releases, :google_plus_likes, :integer
    add_column :android_app_releases, :top_dev, :boolean
    add_column :android_app_releases, :in_app_purchases, :boolean
    add_column :android_app_releases, :required_android_version, :string
    add_column :android_app_releases, :content_rating, :string
    
    add_column :apps, :company_id, :integer
    add_column :apps, :name, :string
    
    add_column :companies, :employee_count, :integer
    add_column :companies, :industry, :string
    add_column :companies, :type, :string
    add_column :companies, :funding, :integer
    add_column :companies, :inc_5000_rank, :integer
    
    add_column :languages, :name, :string
    
    add_column :ios_in_app_purchases, :name, :string
    add_column :ios_in_app_purchases, :ios_app_release_id, :integer
    add_column :ios_in_app_purchases, :price, :integer
    
    add_column :android_in_app_purchase_ranges, :android_app_release_id, :integer
    add_column :android_in_app_purchase_ranges, :min, :integer
    add_column :android_in_app_purchase_ranges, :max, :integer
    
    add_column :android_app_download_ranges, :android_app_release_id, :integer
    add_column :android_app_download_ranges, :min, :integer
    add_column :android_app_download_ranges, :max, :integer
    
    add_column :android_app_review_snapshots, :android_app_release_id, :integer
    add_column :android_app_review_snapshots, :average, :float
    add_column :android_app_review_snapshots, :total, :integer
    add_column :android_app_review_snapshots, :stars5, :integer
    add_column :android_app_review_snapshots, :stars4, :integer
    add_column :android_app_review_snapshots, :stars3, :integer
    add_column :android_app_review_snapshots, :stars2, :integer
    add_column :android_app_review_snapshots, :stars1, :integer
    
  end
end
