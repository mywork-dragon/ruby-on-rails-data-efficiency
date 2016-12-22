class GiphyService

  def gif(search_term)
    @search_term = search_term
    get_search_html

    random_gif
  end

  def get_search_html
    search_html_raw = GiphyApi.search_html(@search_term)
    @search_html = Nokogiri::HTML(search_html_raw)
  end

  def random_gif
    figures = @search_html.css('figure')
    ids = figures.map do |figure| 
      begin
        image = figure.at_css('img')
        url = image['data-animated']

        md = url.match(/\/media\/(.*)\//)

        md.captures.first
      rescue => e
        nil
      end
    end.compact

    id = ids.sample

    return nil if id.blank?

    "http://i.giphy.com/#{id}.gif"
  end

  class << self

    def gif(search_term)
      self.new.gif(search_term)
    end

  end

end
