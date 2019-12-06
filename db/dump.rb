# frozen_string_literal: true

require "emoji"
require "json"
require_relative "./emoji-test-parser"

items = []

_, categories = EmojiTestParser.parse(File.expand_path("../vendor/unicode-emoji-test.txt", __dir__))
seen_existing = {}

categories.each do |category|
  category[:emoji].each do |sub_category|
    sub_category[:emoji].each do |emoji_item|
      raw = emoji_item[:sequences][0]
      existing_emoji = Emoji.find_by_unicode(raw) || Emoji.find_by_unicode("#{raw}\u{fe0f}")
      if seen_existing.key?(existing_emoji)
        existing_emoji = nil
      else
        seen_existing[existing_emoji] = true
      end
      description = emoji_item[:description].sub(/^E\d+(\.\d+)? /, "")
      output_item = {
          :emoji => raw,
          :description => description,
          :category => category[:name]
      }
      if existing_emoji
        output_item.update(
            :aliases => existing_emoji.aliases,
            :tags => existing_emoji.tags,
            :unicode_version => existing_emoji.unicode_version,
            :ios_version => existing_emoji.ios_version
        )
      else
        output_item.update(
            :aliases => [description.gsub(%r{\W+}, "_").downcase],
            :tags => [],
            :unicode_version => "12.1",
            :ios_version => "13.2"
        )
      end
      output_item[:skin_tones] = true if emoji_item[:skin_tones]
      items << output_item
    end
  end
end

missing_emoji = Emoji.all.reject { |e| e.custom? || seen_existing.key?(e) }
if missing_emoji.any?
  warn "Error: these `negarmoji.json` entries were not matched:"
  warn missing_emoji.map { |e| format("%s (%s)", e.hex_inspect, e.name) }
  exit 1
end

Emoji.all.select(&:custom?).each do |emoji|
  items << {
      :aliases => emoji.aliases,
      :tags => emoji.tags
  }
end

trap(:PIPE) { abort }

puts JSON.pretty_generate(items)
         .gsub("\n\n", "\n")
         .gsub(%r{,\n( +)}) { format("\n%<regex>s, ", :regex => Regexp.last_match(1)[2..-1]) }
