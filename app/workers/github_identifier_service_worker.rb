class GithubIdentifierServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  def perform(sdk_id)
    sdk = IosSdk.find(sdk_id)
    last_pod = sdk.cocoapods.last
    url = (last_pod.git if last_pod && last_pod.git && last_pod.git.include?('github')) || sdk.website
    data = GithubService.get_repo_data(url)
    if data['message'] == 'Not Found'
      # should do something
      return nil
    end
    begin
      sdk.update(github_repo_identifier: data['id'])
    rescue
      if Rails.env.development?
        id = IosSdk.select(:id).where(github_repo_identifier: data['id']).first.id
        `echo '#{id} #{sdk_id}' >> collisions.txt` if Rails.env.development?
      end
    end
  end
end