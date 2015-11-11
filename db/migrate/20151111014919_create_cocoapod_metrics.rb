class CreateCocoapodMetrics < ActiveRecord::Migration
  def change
    create_table :cocoapod_metrics do |t|

      t.integer :ios_sdk_id
      t.integer :stats_download_total
      t.integer :stats_download_week
      t.integer :stats_download_month
      t.integer :stats_app_total
      t.integer :stats_app_week
      t.integer :stats_tests_total
      t.integer :stats_tests_week
      t.datetime :stats_created_at
      t.datetime :stats_updated_at
      t.integer :stats_extension_week
      t.integer :stats_extension_total
      t.integer :stats_watch_week
      t.integer :stats_watch_total
      t.integer :stats_pod_try_week
      t.integer :stats_pod_try_total
      t.boolean :stats_is_active

      t.integer :github_subscribers
      t.integer :github_stargazers
      t.integer :github_forks
      t.integer :github_contributors
      t.integer :github_open_issues
      t.integer :github_open_pull_requests
      t.datetime :github_created_at
      t.datetime :github_updated_at
      t.string :github_language
      t.integer :github_closed_issues
      t.integer :github_closed_pull_requests

      t.integer :cocoadocs_install_size
      t.integer :cocoadocs_total_files
      t.integer :cocoadocs_total_comments
      t.integer :cocoadocs_total_lines_of_code
      t.integer :cocoadocs_doc_percent
      t.integer :cocoadocs_readme_complexity
      t.string :cocoadocs_initial_commit_date
      t.string :cocoadocs_rendered_readme_url
      t.datetime :cocoadocs_created_at
      t.datetime :cocoadocs_updated_at
      t.string :cocoadocs_license_short_name
      t.string :cocoadocs_license_canonical_url
      t.integer :cocoadocs_total_test_expectations
      t.string :cocoadocs_dominant_language
      t.integer :cocoadocs_quality_estimate
      t.boolean :cocoadocs_builds_independently
      t.boolean :cocoadocs_is_vendored_framework
      t.string :cocoadocs_rendered_changelog_url
      t.text :cocoadocs_rendered_summary

      t.timestamps
    end

    add_index :cocoapod_metrics, :ios_sdk_id, unique: true
  end
end
