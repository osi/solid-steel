module Ninja

  require "hpricot"
  require "net/http"

  URL = "http://solidsteel.ninjatune.net/index.php?id="

  class Archive
    
    attr_reader :episodes

    def initialize(archive_text)
      doc = Hpricot.parse(archive_text)
      # Omit first, as its junk
      @episodes = Array.new

      doc.search("select[@id='select_show]/option")[1..-2].each do |option|
        if not option["value"].strip.empty?
          if option.inner_text =~ /(\d{2})\/(\d{2})\/(\d{4}) . (.*)/
            year = $3.to_i
            if year > 1997
              @episodes << Episode.new(Time.gm(year, $2.to_i, $1.to_i), $4.rstrip, option["value"])
            end
          else
            raise "Failed to match #{option.inner_text}"
          end
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
      @segments = nil
    end
    
    def human_date
      date.strftime('%Y-%m-%d')
    end
    
    # def segments
    #   if @segments.nil?
    #     @segments = Episode.parse_segments Net::HTTP.get(URI.parse(URL + @id))
    #   end
    #   
    #   @segments
    # end
    
    def to_s
      "\##{@id} - #{human_date} - #{@artists}"
    end
    # 
    # def self.parse_segments(text)
    #   Hpricot.parse(text).search("div.column_middle div.entry_releases").map { |element| Segment.parse(element) }
    # end
  end
  
  # class Segment
  #   attr_accessor :artist, :tracks
  #   
  #   def self.parse(element)
  #     segment = Segment.new 
  #     segment.artist = element.search("strong").inner_text[11..-1]
  #     # puts "INNER TEXT '#{element.search("strong").inner_text[11..-1]}' '#{segment.artist}'"
  #     segment.tracks = element.search("table tr")[1..-1].map { |row| Song.parse(row) }
  #     
  #     segment
  #   end
  # end
  # 
  # class Song
  #   attr_accessor :artist, :title, :label
  #   
  #   def self.parse(row)
  #     cells = row.search("td")
  #     song = Song.new
  #     song.artist = cells[0].inner_text.strip
  #     song.title = cells[2].inner_text.strip
  #     song.label = cells[4].inner_text.strip
  #     song
  #   end
  # end
end
