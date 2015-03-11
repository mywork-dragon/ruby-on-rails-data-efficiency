# Scraping helper functions
# @author Jason Lew
class ScrapeHelper

  puts "ScrapeHelper"
  
  class << self
    
    def node_to_text_replacing_brs(node)
      node.children.map{|e| e.name == "br" ? "\n" : e.text}.join('')
    end
  end
  
end
