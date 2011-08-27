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
        total_time = total_time_of tracks
        
        if total_time > 110
          fixup_unevenly_split_show episode, tracks, total_time
        else
          puts "PARTIAL SHOW #{episode} #{tracks}\n\t#{tracks.join("\n\t")}"
          puts "-segments:\n\t#{episode.segments.map {|s| s.artist }.join("\n\t")}"
        end
      end
    end    
  end
  
  def fixup_unevenly_split_show(episode, tracks, total_time)
    puts "need to fix #{episode}:\n\t#{tracks.join("\n\t")}"
    tracks = tracks.sort { |t1, t2| t1.track_number <=> t2.track_number }
    percentages = time_percentages tracks, total_time
    segment_counts = segment_counts percentages
    # tracks.each_with_index { |t, i| puts "#{percentages[i]} #{segment_counts[i]} #{t.track_number} #{t.artist}" }
    
    start = 0
    
    tracks.each_with_index do |track, i|
      segment_count = segment_counts[i]
      artists = episode.segments[start,segment_count].map { |s| s.artist }.uniq.join(", ")
      
      puts "#{track.track_number} from #{track.artist} -> #{artists}"
      
      update_track track, i+1, tracks.length, artists, episode
      
      start += segment_count
    end
    
    puts ""
  end
  
  def segment_counts(percentages)
    percentages.map do |p|
      if p > 60
        3
      elsif p > 39
        2
      else
        1
      end
    end
  end
  
  def time_percentages(tracks, total_time)
    tracks.map { |t| (t.duration / total_time.to_f * 100).to_i }
  end
  
  def total_time_of(tracks)
    total_time = tracks.map { |t| t.duration }.reduce(:+)
  end
  
  def handle_even_split(episode, tracks)
    total_time = total_time_of tracks

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