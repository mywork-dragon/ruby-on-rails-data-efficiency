class FbStatusWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default


  # if root = true, get the number of pages for the current category and pass off to different workers
  def perform(url, create_pages)

    if create_pages
      kick_off_pages(url)
    else
      store_current_page(url)
    end
  end

  def store_current_page(url)
    html = Nokogiri::HTML(open(url))
    links = html.css('section#content article.status-publish h2.entry-title>a')
    links.each do |link|
      FbStatus.create(status: link.content)
    end

  end

  def kick_off_pages(url)

    return "Don't do this in development" if Rails.env.development?

    begin
      html = Nokogiri::HTML(open(url))
      span = html.css('span.pages')
      pages = if span.present?
        Integer(html.css('span.pages').children.first.content.split.last)
      else
        1
      end
      puts "Pages: #{pages}"
    rescue
      puts "Could not get pages for url: #{url}"
      return
    end

    if batch.nil?
      pages.times do |i|
        FbStatusWorker.perform_async(File.join(url, 'page', (i+1).to_s, ''), false)
      end
    else
      batch.jobs do
        pages.times do |i|
          FbStatusWorker.perform_async(File.join(url, 'page', (i+1).to_s, ''), false)
        end
      end
    end
  end
end