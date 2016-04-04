class GithubIdentifierServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  def perform(sdk_id)
    sdk = IosSdk.find(sdk_id)
    last_pod = sdk.cocoapods.last
    url = (last_pod.git if last_pod && last_pod.git && last_pod.git.include?('github')) || sdk.website
    data = GithubApi.repo_info_from_url(url)
    return nil if data['message'] == 'Not Found'
    # TODO: should do something about not finding
    begin
      sdk.update(github_repo_identifier: data['id'])
    rescue => e
      if Rails.env.development?
        id = IosSdk.select(:id).where(github_repo_identifier: data['id']).first.id
        `echo '#{id} #{sdk_id}' >> collisions.txt` if Rails.env.development?
      else
        raise e
      end
    end
  end
end
