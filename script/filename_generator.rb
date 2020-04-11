#!/usr/bin/env ruby
# frozen_string_literal: true

require "negarmoji"
require "json"

file_names = Emoji.all.map(&:image_filename).flatten.sort

File.open(ARGV[0], "w") do |file|
  file.write(JSON.pretty_generate(file_names))
end
