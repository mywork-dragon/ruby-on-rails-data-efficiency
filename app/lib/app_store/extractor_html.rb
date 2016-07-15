# Extract attributes from iTunes page
# NOT FULLY IMPLEMENTED. will complete later

require_relative 'extractor_base'

module AppStoreHelper
  class ExtractorHtml < AppStoreHelper::ExtractorBase

    # WARNING: these methods have only been tested on US App Store
    def initialize(scrape_html)
      @data = Nokogiri::HTML(scrape_html)
    end

    def name
      raise Unimplemented
      @data = Nokogiri::HTML(scrape_html)
    end

    def description
      raise Unimplemented
      @html.css("div.center-stack > .product-review > p")[0].text_replacing_brs
      @html.css('#title > div.left > h1').text
    end

    def release_notes
      raise Unimplemented
      @html.css("div.center-stack > .product-review > p")[1].text
    end

    def version
      raise Unimplemented
      size_text = @html.css('li').select{ |li| li.text.match(/Version: /) }.first.children[1].text
    end

    def price
      raise Unimplemented
      price = 0.0
      price_text = @html.css(".price").text.gsub("$", "")

      price = price_text.to_f unless price_text.strip == "Free"

      price*100.to_i
    end

    def seller_url
      raise Unimplemented
      children = @html.css(".app-links").children
      children.select{ |c| c.text.match(/Site\z/) }.first['href']
    end

    def categories
      raise Unimplemented
      primary = @html.css(".genre").children[1].text
      {primary: primary, secondary: []}
    end

    def size
      raise Unimplemented
      size_text = @html.css('li').select{ |li| li.text.match(/Size: /) }.first.children[1].text
      Filesize.from(size_text).to_i
    end

    def seller
      raise Unimplemented
      @html.css('li').select{ |li| li.text.match(/Seller: /) }.first.children[1].text
    end

    def by
      raise Unimplemented
      @html.css('#title > div.left').children.find{ |c| c.name == 'h2' }.text.gsub(/\ABy /, '')
    end

    def developer_app_store_identifier
      raise Unimplemented
    end

    def ratings
      raise Unimplemented
    end

    def recommended_age

      raise Unimplemented
    end

    def required_ios_version
      raise Unimplemented
    end

    def first_released
      raise Unimplemented
    end

    def screenshot_urls
      raise Unimplemented
    end

    def released
      raise Unimplemented
    end

    def ratings_current_stars
      raise Unimplemented
    end

    def ratings_current_count
      raise Unimplemented
    end

    def ratings_all_stars
      raise Unimplemented
    end

    def ratings_all_count
      raise Unimplemented
    end

    def icon_url_512x512
      raise Unimplemented
    end

    def icon_url_100x100
      raise Unimplemented
    end

    def icon_url_60x60
      raise Unimplemented
    end

    def game_center_enabled
      raise Unimplemented
    end

    def bundle_identifier
      raise Unimplemented
    end

    def currency
      raise Unimplemented
    end

    def category_ids
      raise Unimplemented
    end

    ####### HTML only methods ########
    def support_url
      raise Unimplemented
    end

    def languages
      raise Unimplemented
    end

    def in_app_purchases
      lis = @data.css("#left-stack > div.extra-list.in-app-purchases > ol > li")
      lis.map{ |li| { name: li.css("span.in-app-title").text, price: li.css("span.in-app-price").text } }
    end

    def has_in_app_purchases
      in_app_purchases.any?
    end

    def editors_choice
      raise Unimplemented
    end

    def copywright
      raise Unimplemented
    end

    def seller_url_text
      raise Unimplemented
    end

    def support_url_text
      raise Unimplemented
    end

    def icon_urls
      raise Unimplemented
    end

    def app_link_urls
      @data.css('.app-links').children.map { |x| x['href'] }.compact
    end
  end
end
