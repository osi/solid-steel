#!/usr/bin/env ruby -wKU -rrubygems

require "itunes"
require "ninja"
require "resolver"
require "multipart"
require "pp"

# VERSION = "0.1"

library = Library.new
# archive = Ninja::Archive.from_file
archive = Ninja::Archive.from_net

resolver = Resolver.new(archive)

multi_parts = Multipart.new

library.tracks.select { |t| t.episode_ID.empty? }.each do |track|
  episode = resolver.find_episode(track)
  
  if episode.nil?
    puts "NO MATCH FOR #{track}"
    next
  elsif track.complete_show?
    track.track_count = ''
    track.track_number = ''
    track.artist = episode.artists
    track.episode = episode
    puts "#{track}"
  else
    multi_parts[episode] << track
  end
end

multi_parts.process

library.tracks.inject({}) do |hash, track|
  year = track.album[-4..-1]
  
  hash[year] ||= []
  hash[year] << track
  
  hash
end.each do |year, tracks|
  puts "#{year} has #{tracks.length} tracks"
  disc = 0
  episode_ID = nil
  tracks.sort { |a,b| a.episode_ID <=> b.episode_ID }.each do |track|
    disc += 1 if track.episode_ID != episode_ID
    track.disc_number = disc unless track.disc_number == disc
    episode_ID = track.episode_ID
  end
  tracks.each do |track| 
    track.disc_count = disc unless track.disc_count == disc
  end
end