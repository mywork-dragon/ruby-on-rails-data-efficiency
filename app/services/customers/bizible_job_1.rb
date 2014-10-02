class ScrapeService

  def initialize(options = {})
  end

  def run
    # scrape_job = ScrapeJob.find_by_notes("notes")
    # installations = scrape_job.installations
    #
    # #open file
    #
    #   #for each line
    #   Installation =
  end
  
  class << self
  
    def run
      ScrapeService.new.run
    end
  
  end
end

