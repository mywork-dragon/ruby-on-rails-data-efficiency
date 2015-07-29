class EpfService

  NUMBER_OF_FILES = 250 # Should be less than or equal to the number of threads

  class << self
    
    def run
      #TODO: call everything
    end
    
    def download
      #TODO: implement
    end
    
    def split(filename)
      number_of_digits = NUMBER_OF_FILES.to_s.length
      `split -n #{NUMBER_OF_FILES} -a #{number_of_digits} -d #{filename}_split`
    end
    
    def get_partial_data_from_end(filename)
      max_lines = 5e3
      
      for n in (1..max_lines)
        tail = `tail -n #{n} #{filename}`
        
        if tail.match(/\^B\n/) #delimiter
          partial_data = tail.split('^B\n')[1]
          break
        end
      
        raise "Could not find delimiter after #{max_lines} lines" if n == max_lines
      end
      
      partial_data
    end
    
    def add_partial_data_to_beginning(partial_data, file)
      `sed -i '1s/^/#{partial_data}/' #{file}`
    end
    
  end

end