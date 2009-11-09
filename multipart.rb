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
      if not handle_even_split(episode, tracks)
        puts "need to fix #{episode} #{tracks}"
      end
    end    
  end
  
  def handle_even_split(episode, tracks)
    times = tracks.map { |t| t.duration }
    total_time = times.reduce(:+)

    artists = episode.artists.split(/,|&|and/).map { |s| s.strip }

    if tracks.length == 2 and artists.length == 2
      p1 = tracks[0].duration / total_time.to_f
      p2 = tracks[1].duration / total_time.to_f
      delta = (p1 - p2).abs

      if delta < 0.1
        track_one = tracks.find { |track| track.artist == artists[0] }

        if track_one.nil?
          track_two = tracks.find { |track| track.artist == artists[1] }
          track_one = tracks.reject { |track| track == track_two }[0] if not track_two.nil?
        else
          track_two = tracks.reject { |track| track == track_one }[0]
        end

        if not (track_one.nil? and track_two.nil?)
          update_track(track_one, 1, 2, artists[0], episode)
          update_track(track_two, 2, 2, artists[1], episode)
          return true
        end
      end
    end
    
    false
  end
  
  def update_track(track, number, count, artist, episode)
    track.track_count = count
    track.track_number = number
    track.artist = artist
    track.episode = episode
  end
end