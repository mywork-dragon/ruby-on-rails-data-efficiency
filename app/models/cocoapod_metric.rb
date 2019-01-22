# == Schema Information
#
# Table name: cocoapod_metrics
#
#  id                                :integer          not null, primary key
#  ios_sdk_id                        :integer
#  success                           :boolean
#  stats_download_total              :integer
#  stats_download_week               :integer
#  stats_download_month              :integer
#  stats_app_total                   :integer
#  stats_app_week                    :integer
#  stats_tests_total                 :integer
#  stats_tests_week                  :integer
#  stats_created_at                  :datetime
#  stats_updated_at                  :datetime
#  stats_extension_week              :integer
#  stats_extension_total             :integer
#  stats_watch_week                  :integer
#  stats_watch_total                 :integer
#  stats_pod_try_week                :integer
#  stats_pod_try_total               :integer
#  stats_is_active                   :boolean
#  github_subscribers                :integer
#  github_stargazers                 :integer
#  github_forks                      :integer
#  github_contributors               :integer
#  github_open_issues                :integer
#  github_open_pull_requests         :integer
#  github_created_at                 :datetime
#  github_updated_at                 :datetime
#  github_language                   :string(191)
#  github_closed_issues              :integer
#  github_closed_pull_requests       :integer
#  cocoadocs_install_size            :integer
#  cocoadocs_total_files             :integer
#  cocoadocs_total_comments          :integer
#  cocoadocs_total_lines_of_code     :integer
#  cocoadocs_doc_percent             :integer
#  cocoadocs_readme_complexity       :integer
#  cocoadocs_initial_commit_date     :datetime
#  cocoadocs_rendered_readme_url     :string(191)
#  cocoadocs_created_at              :datetime
#  cocoadocs_updated_at              :datetime
#  cocoadocs_license_short_name      :string(191)
#  cocoadocs_license_canonical_url   :string(191)
#  cocoadocs_total_test_expectations :integer
#  cocoadocs_dominant_language       :string(191)
#  cocoadocs_quality_estimate        :integer
#  cocoadocs_builds_independently    :boolean
#  cocoadocs_is_vendored_framework   :boolean
#  cocoadocs_rendered_changelog_url  :string(191)
#  cocoadocs_rendered_summary        :text(65535)
#  created_at                        :datetime
#  updated_at                        :datetime
#

class CocoapodMetric < ActiveRecord::Base
  belongs_to :ios_sdk
  has_many :cocoapod_metric_exceptions
end
