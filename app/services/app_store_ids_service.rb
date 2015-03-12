#!/usr/bin/ruby

require "rubygems"
require "typhoeus"
require "nokogiri"
require "open-uri"
require "set"

# helper method - opens url, returning Nokogiri object
def openUrl(url)

  page = open(url)

  Nokogiri::HTML(page)

  # Rescues error if issue opening URL
  rescue => e
    case e
      when OpenURI::HTTPError
        puts "HTTPError - could not open page"
        return nil
      when URI::InvalidURIError
        puts "InvalidURIError - could not open page"
        return nil
      else
        raise e
  end
end

# scrapes Apple Appstore, returning Set of all unique app ids as Integers
# example:
# find & converts app link: "https://itunes.apple.com/us/app/clearweather-color-forecast/id550882015?mt=8"
# into "550882015", rutrning Set of all these ids
def scrape_appstore()

    appIds = Set.new

    # url string param for each category of app
    appUrlIds = [
=begin
        "ios-books/id6018",
        "ios-business/id6000",
=end
        "ios-catalogs/id6022",
=begin
        "ios-education/id6017",
        "ios-entertainment/id6016",
        "ios-finance/id6015",
        "ios-food-drink/id6023",
        "ios-games/id6014",
        "ios-health-fitness/id6013",
        "ios-lifestyle/id6012",
        "ios-medical/id6020",
        "ios-music/id6011",
        "ios-navigation/id6010",
        "ios-news/id6009",
        "ios-newsstand/id6021",
        "ios-photo-video/id6008",
        "ios-productivity/id6007",
        "ios-reference/id6006",
        "ios-social-networking/id6005",
        "ios-sports/id6004",
        "ios-travel/id6003",
        "ios-utilities/id6002",
        "ios-weather/id6001"
=end
    ]

    # url string param for each sub group of app category
    appUrlLetters = [
        "A"
=begin
        ,
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z",
        "*"
=end
    ]

    # for each category of app
    appUrlIds.each { |appid|

        # for each beginning letter of app name in category
        appUrlLetters.each { |appletter|

            lastPage = false

            pageNum = 0

            while !lastPage 

                pageNum += 1

                puts "SCRAPING    CATEGORY: " + appid + "    SUB GROUP: " + appletter + "    PAGE: " + pageNum.to_s + "..."

                # Compiles link for page of app list
                # Example: https://itunes.apple.com/us/genre/ios-weather/id6001?mt=8&letter=C&page=2
                dom = openUrl("https://itunes.apple.com/us/genre/" + appid + "?letter=" + appletter + "&page=" + pageNum.to_s)

                if dom != nil

                    # wrapper for #selectedcontent columns
                    results = dom.css("#selectedcontent > div.column")

                    # iterate over each of the result wrapper elements
                    results.each { |result|

                        links = result.css("ul > li").css("a")

                        # if number of app links on page is 1 or 0, last page has been reached
                        if links.length < 2
                            lastPage = true # stops loop upon next iteration
                        end

                        # finds the href link inside the <a> and strips out the id, casting it to an Integer
                        # Before: "https://itunes.apple.com/us/app/clearweather-color-forecast/id550882015?mt=8"
                        # After: 550882015
                        links.map { |link|
                            appIds << link['href'].gsub('?mt=8','').split('id').last.to_i
                        }

                    }

                end

            end

        }

    }

    puts appIds.inspect

end

scrape_appstore()
