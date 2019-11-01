# frozen_string_literal: true

require 'emoji'
require 'json'
require_relative './emoji-test-parser'

items = []

_, categories = EmojiTestParser.parse(File.expand_path("../../vendor/unicode-negarmoji-test.txt", __FILE__))
seen_existing = {}

categories.each { |category|
  category[:emoji].each { |sub_category|
    sub_category[:emoji].each { |emoji_item|
      unicodes = emoji_item[:sequences].sort_by(&:bytesize)
      existing_emoji = nil
      unicodes.detect do |raw|
        existing_emoji = Emoji.find_by_unicode(raw)
      end
      existing_emoji = nil if seen_existing.key?(existing_emoji)
      output_item = {
          emoji: unicodes[0],
          description: emoji_item[:description],
          category: category[:name],
      }
      if existing_emoji
        eu = existing_emoji.unicode_aliases
        preferred_raw = eu.size == 2 && eu[0] == "#{eu[1]}\u{fe0f}" ? eu[1] : eu[0]
        output_item.update(
            emoji: preferred_raw,
            aliases: existing_emoji.aliases,
            tags: existing_emoji.tags,
            unicode_version: existing_emoji.unicode_version,
            ios_version: existing_emoji.ios_version,
        )
        seen_existing[existing_emoji] = true
      else
        output_item.update(
            aliases: [emoji_item[:description].gsub(/\W+/, '_').downcase],
            tags: [],
            unicode_version: "12.0",
            ios_version: "13.0",
        )
      end
      output_item[:skin_tones] = true if emoji_item[:skin_tones]
      items << output_item
    }
  }
}

missing_emoji = Emoji.all.reject { |e| e.custom? || seen_existing.key?(e) }
if missing_emoji.any?
  $stderr.puts "Error: these `negarmoji.json` entries were not matched:"
  $stderr.puts missing_emoji.map { |e| "%s (%s)" % [e.hex_inspect, e.name] }
  exit 1
end

Emoji.all.select(&:custom?).each { |emoji|
  items << {
      aliases: emoji.aliases,
      tags: emoji.tags,
  }
}

trap(:PIPE) { abort }

puts JSON.pretty_generate(items)
         .gsub("\n\n", "\n")
         .gsub(/,\n( +)/) { "\n%s, " % $1[2..-1] }
