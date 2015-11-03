class CocoapodValidateWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :scraper

	def perform(cocoapod_name)

		# Get the latest version
		versions = GithubService.get_contents("Cocoapods/Specs", "Specs/#{cocoapod_name}")
		latest = version.sort_by { |x| x["version"] }.last
	end

end
