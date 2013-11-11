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
    
    raise "Unable to determine episode for #{track}"
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
    when /Solid Steel::(\d{2}).(\d{2}).(\d{4})/
      Time.gm($3, $2, $1)
    when /Solid Steel - (\d{2}).(\d{2}).(\d{4})/
      Time.gm($3, $2, $1)
    when /(\d{2})-(\d{2})-(\d{2})/
      Time.gm(2000 + $1.to_i, $2, $3)
    when /(\d{2})-(\d{2})-(\d{2})-\d{2}/
      Time.gm(2000 + $1.to_i, $2, $3)
    end
  end
  
end


# [
# "Solid Steel (09 OCT 2009) / DK -> Pablo, King Cannibal , DK on Fri Oct 23 00:00:00 UTC 2009",
# "Solid Steel 2006-08-18",
# "Solid Steel (10/04/09)",
# "Solid Steel 27th Feb",
# "Solid Steel 20th-Feb-09",
# "Solid Steel (23 Jan)",
# "Solid Steel (26.12.08)",
# "Solid Steel (15 Aug)",
# "Solid Steel::27.11.2009",
# "Solid Steel - 08.01.2010",
# "10-02-05"
# ].each do |s|
# puts Resolver.new(nil).air_date_from_track_name(s, 2009)
# end
