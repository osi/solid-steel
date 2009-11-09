require "appscript"

class Library
  include Appscript

  def initialize
    @itunes = app("iTunes")
    @playlist = @itunes.playlists["Solid Steel"].get
  end

  def tracks
    @playlist.tracks.get.map { |track| Track.new(track) }.reject { |track| track.name.include?("Podcast") }
  end

end

class Track
  def initialize(itunes_track)
    @itunes_track = itunes_track
  end
  
  def self.properties(*props)
    props.each do |prop|
      define_method prop do
        @itunes_track.send(prop).get
      end
      define_method "#{prop}=" do |value|
        @itunes_track.send(prop).set value
      end
    end
  end
  
  def duration
    segments = time.split(':')
    case segments.length
    when 3
      segments[0].to_i * 60 + segments[1].to_i
    when 2
      segments[0].to_i
    else
      raise "unable to calculate duration from #{time}"
    end
  end
  
  def episode=(episode)
    self.episode_ID = episode.id
    self.name = "Solid Steel #{episode.human_date}"
    self.album = "Solid Steel #{episode.date.year}"
    self.compilation = true
  end
  
  def complete_show?
    duration > 110
  end
  
  properties :name, :artist, :album, :year, :date_added, :lyrics, :time, :album, :track_number, :track_count, :compilation, :comment, :episode_ID

  def to_s
    "#{name} / #{artist}"
#     <<-EOF
# Title : #{name}
# Artist: #{artist}
# Track : #{track_number}/#{track_count}
# Album : #{album}
# Added : #{date_added}
# Year  : #{year}
# Time  : #{time}
# 
# EOF
  end


end  
