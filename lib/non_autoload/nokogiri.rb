module Nokogiri

  module XML

    class Node

      def text_replacing_brs
        children.map{|e| e.name == "br" ? "\n" : e.text}.join('')
      end

    end

  end

end