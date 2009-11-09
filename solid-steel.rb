#!/usr/bin/env ruby -wKU -rrubygems

require "itunes"
require "ninja"
require "resolver"
require "multipart"
require "pp"

# VERSION = "0.1"

library = Library.new
archive = Ninja::Archive.from_file

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