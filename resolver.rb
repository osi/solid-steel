class Resolver
  attr_reader :archive
  
  def initialize(archive)
    @archive = archive
  end
  
  def find_episode(track)
    episode = match_by_air_date(track.name, track.date_added.year)
    
    if not episode.nil?
      # puts "** AIR DATE MATCH #{track.artist} -> #{episode.artists}"
      return episode
    end
    
    episodes = archive.episodes.find_all { |e| track.date_added > e.date }
    
    if episodes.empty?
      STDERR.puts "No episode immediately after date added for #{track}"
      return nil
    end
    
    rejects = Array.new
    
    episodes.each do |e|
      if "Solid Steel Show" == track.name[0, 16] 
        artist_in_track = track.name[17..-1]
      
        if fuzzy_match_names(artist_in_track, e.artists)
          # puts "** FUZZY NAME MATCH #{artist_in_track} -> #{e.artists}"
          episode = e
          break
        end

        rejects << "NO FUZ LUV \n\t#{clean_name(artist_in_track)}\n\t#{clean_name(e.artists)}"
      elsif not track.artist.empty?
        if fuzzy_match_names(track.artist, e.artists)
          # puts "** FUZZY NAME MATCH #{artist_in_track} -> #{e.artists}"
          episode = e
          break
        end

        rejects << "NO FUZ LUV \n\t#{clean_name(track.artist)}\n\t#{clean_name(e.artists)}"
      end
    end

    puts rejects if episode.nil?
    
    episode
  end
  
  def clean_name(name)
    name.gsub(/[_,\-\&]/, ' ').downcase.strip.squeeze(' ')
  end
  
  def fuzzy_match_names(track, episode)
    track = clean_name(track)
    episode = clean_name(episode)

    if track == episode
      true
    elsif track.include?(episode) or episode.include?(track)
      true
    elsif episode =~ /(.*) \(classic edition\)$/ and track.index($1) == 0
      true
    else
      track_components = track.split(' ')
      episode_components = episode.split(' ')
      # episode.split(' ').each { |t| ++matches if track_tokens.remove(t) }
      
      matches = (track_components & episode_components).length
      
      if track_components.length == episode_components.length
        ratio = matches.to_f / track_components.length
        
        ratio >= 0.75
      else
        ((matches.to_f / track_components.length) + (matches.to_f / episode_components.length)) / 2 >= 0.7
      end
    end
  end
  
  def match_by_air_date(name, year)
    air_date = air_date_from_track_name(name, year)

    return if air_date.nil?

    episode = find_episode_for_air_date(air_date)
    
    if episode.nil? and year > 2002
      # puts "** NO AIR DATE MATCH for #{air_date}"
      match_by_air_date name, year-1
    else
      episode
    end
  end
  
  def find_episode_for_air_date(date)
    archive.episodes.find { |e| date == e.date}
  end
  
  def air_date_from_track_name(name, year)
    case name
    when /Solid Steel \((\d+) ([a-z]+) (\d+)\)/i
      Time.gm($3, $2, $1)
    when /Solid Steel (\d{4})-(\d{2})-(\d{2})/i
      Time.gm($1, $2, $3)
    when /Solid Steel \((\d{2})\/(\d{2})\/(\d{2})\)/i
      Time.gm("20#{$3}", $2, $1)
    when /Solid Steel \((\d{2}).(\d{2}).(\d{2})\)/i
      Time.gm("20#{$3}", $2, $1)
    when /Solid Steel (\d{2}).(\d{2}).(\d{2})/i
      Time.gm("20#{$3}", $2, $1)
    when /Solid Steel \(([a-z]+) (\d+)\)/i
      Time.gm(year, $1, $2)
    when /Solid Steel (\d+)(?:th|st) ([a-z]+)/i
      Time.gm(year, $2, $1)
    when /Solid Steel (\d+)(?:th|st)-([a-z]+)-(\d+)/i
      Time.gm("20#{$3}", $2, $1)
    when /Solid Steel \((\d+) ([a-z]+)\)/i
      Time.gm(year, $2, $1)
    end
  end
  
end

# 
# [
# "Solid Steel (09 OCT 2009) / DK -> Pablo, King Cannibal , DK on Fri Oct 23 00:00:00 UTC 2009",
# "Solid Steel 2006-08-18",
# "Solid Steel (10/04/09)",
# "Solid Steel 27th Feb",
# "Solid Steel 20th-Feb-09",
# "Solid Steel (23 Jan)",
# "Solid Steel (26.12.08)",
# "Solid Steel (15 Aug)"
# ].each do |s|
# 
# puts Resolver.new(nil).air_date_from_track_name(s, Time.now)
# 
# end
