class Multipart
  def initialize
    @multi_parts = Hash.new { |hash, key| hash[key] = Array.new }
  end
  
  def [](episode)
    @multi_parts[episode]
  end
  
  def []=(episode, track)
    @multi_parts[episode] = track
  end
  
  def process
    @multi_parts.each_pair do |episode, tracks|
      puts "#{episode} -> #{tracks}"
      tracks.each do |track|
        if track.track_number == 0 and track.name =~ /\d{2}-\d{2}-\d{2}-(\d{2})/
          track.track_count = tracks.length
          track.track_number = $1.to_i
          track.episode = episode
        else
          raise "Unable to determine track number for #{track.name} #{track.track_number}"
        end
      end
    end    
  end
end