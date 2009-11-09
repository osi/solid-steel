module Ninja

  require "hpricot"
  require "net/http"

  class Archive
    URL = "http://www.ninjatune.net/solidsteel/index.php?id="
    
    attr_reader :episodes

    def initialize(archive_text)
      doc = Hpricot.parse(archive_text)
      # Omit first, as its junk
      @episodes = Array.new
      
      current_year = nil
      
      doc.search("select[@name='shows]/option")[1..-2].each do |option|
        if option["value"].empty?
          current_year = option.inner_text[3,4].to_i
        else
          @episodes << Episode.new(Time.gm(current_year, option.inner_text[3,2].to_i, option.inner_text[0,2].to_i), option.inner_html[8..-1].rstrip, option["value"])
        end
      end
    end
    
    def self.from_net
      Archive.new Net::HTTP.get(URI.parse(URL))
    end
    
    def self.from_file
      Archive.new File.read("archive_root.html")
    end
  
  end
  
  class Episode
    attr_reader :date, :artists, :id
    
    def initialize(date, artists, id)
      @date = date
      @artists = artists
      @id = id
    end
    
    def human_date
      date.strftime('%Y-%m-%d')
    end
    
    def to_s
      "\##{@id} - #{human_date} - #{@artists}"
    end
  end

end