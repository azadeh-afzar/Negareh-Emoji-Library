# frozen_string_literal: true

module EmojiTestParser # :nodoc:
  VARIATION_SELECTOR_16 = "\u{fe0f}"
  SKIN_TONES = [
      "\u{1F3FB}", # light skin tone
      "\u{1F3FC}", # medium-light skin tone
      "\u{1F3FD}", # medium skin tone
      "\u{1F3FE}", # medium-dark skin tone
      "\u{1F3FF}" # dark skin tone
  ].freeze
  SKIN_TONES_RE = /(#{SKIN_TONES.join("|")})/o
  SKIP_TYPES = %w(unqualified component)
  module_function

  def parse(filename)
    File.open(filename, "r:UTF-8") do |file|
      parse_file(file)
    end
  end

  def parse_file(io)
    data = []
    emoji_map = {}
    category = nil
    sub_category = nil

    io.each do |line|
      begin
        if line.start_with?("# group: ")
          _, group_name = line.split(":", 2)
          category = {
              :name => group_name.strip,
              :emoji => []
          }
          data << category
          sub_category = nil
        elsif line.start_with?("# subgroup: ")
          _, group_name = line.split(":", 2)
          sub_category = {
              :name => group_name.strip,
              :emoji => []
          }
          category[:emoji] << sub_category
        elsif line.start_with?("#") || line.strip.empty?
          next
        else
          row, desc = line.split("#", 2)
          desc = desc.strip.split(" ", 2)[1]
          codepoints, qualification = row.split(";", 2)
          next if SKIP_TYPES.include?(qualification.strip)
          emoji_raw = codepoints.strip.split.map(&:hex).pack("U*")
          emoji_normalized = emoji_raw
                                 .gsub(VARIATION_SELECTOR_16, "")
                                 .gsub(SKIN_TONES_RE, "")
          emoji_item = emoji_map[emoji_normalized]
          if SKIN_TONES.any? { |s| emoji_raw.include?(s) }
            emoji_item[:skin_tones] = true if emoji_item
            next
          end
          if emoji_item
            emoji_item[:sequences] << emoji_raw
          else
            emoji_item = {
                :sequences => [emoji_raw],
                :description => desc
            }
            emoji_map[emoji_normalized] = emoji_item
            sub_category[:emoji] << emoji_item
          end
        end
      rescue StandardError
        warn format("line: %<line>p", :line => line)
        raise
      end
    end

    [emoji_map, data]
  end
end

if $PROGRAM_NAME == __FILE__
  html_output = false
  if ARGV[0] == "--html"
    ARGV.shift
    html_output = true
  end

  _, categories = EmojiTestParser.parse(File.expand_path("../../vendor/unicode-emoji-test.txt", __FILE__))

  trap(:PIPE) { abort }

  if html_output
    puts "<!doctype html>"
    puts "<meta charset=utf-8>"
    categories.each do |category|
      puts "<h2>#{category[:name]}</h2>"
      category[:emoji].each do |sub_category|
        puts "<h3>#{sub_category[:name]}</h3>"
        puts "<ol>"
        sub_category[:emoji].each do |char|
          puts "<li>"
          char[:sequences].each do |sequence|
            codepoints = sequence.unpack("U*").map { |c| c.to_s(16).upcase }.join(" ")
            printf '<span class=emoji title="%s">%s</span> ', codepoints, sequence
          end
          puts "#{char[:description]}</li>"
        end
        puts "</ol>"
      end
    end
  else
    require "json"
    puts JSON.pretty_generate(categories)
  end
end
