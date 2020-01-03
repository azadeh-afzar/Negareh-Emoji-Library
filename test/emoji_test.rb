require "test_helper"
require_relative "../db/emoji-test-parser"

class EmojiTest < TestCase
  test "fetching all negarmoji" do
    count = Emoji.all.size
    assert count > 845, "there were too few emojis: #{count}"
  end

  test "unicodes set contains the unicodes" do
    min_size = Emoji.all.size
    count = Emoji.all.map(&:unicode_aliases).flatten.size
    assert count > min_size, "there were too few unicode mappings: #{count}"
  end

  test "finding negarmoji by alias" do
    assert_equal "smile", Emoji.find_by_alias("smile").name
  end

  test "finding nonexistent negarmoji by alias returns nil" do
    assert_nil Emoji.find_by_alias("$$$")
  end

  test "finding negarmoji by unicode" do
    emoji = Emoji.find_by_unicode("\u{1f604}") # grinning face with smiling eyes
    assert_equal "\u{1f604}", emoji.raw
  end

  test "finding nonexistent negarmoji by unicode returns nil" do
    assert_nil Emoji.find_by_unicode("\u{1234}")
  end

  test "unicode_aliases" do
    emoji = Emoji.find_by_unicode("\u{2728}") # sparkles
    assert_equal %w[2728 2728-fe0f], emoji.unicode_aliases.map { |u| Emoji::Character.hex_inspect(u) }
  end

  test "unicode_aliases doesn't necessarily include form without VARIATION_SELECTOR_16" do
    emoji = Emoji.find_by_unicode("\u{00a9}\u{fe0f}") # copyright symbol
    assert_equal ["00a9-fe0f"], emoji.unicode_aliases.map { |u| Emoji::Character.hex_inspect(u) }
  end

  test "emojis have tags" do
    emoji = Emoji.find_by_alias("smile")
    assert emoji.tags.include?("happy")
    assert emoji.tags.include?("joy")
    assert emoji.tags.include?("pleased")
  end

  GENDER_EXCEPTIONS = [
      "man_with_gua_pi_mao",
      "woman_with_headscarf",
      "man_in_tuxedo",
      "pregnant_woman",
      "isle_of_man",
      "blonde_woman",
      %r{^couple(kiss)?_},
      %r{^family_}
  ].freeze

  test "emojis have valid names" do
    aliases = Emoji.all.flat_map(&:aliases)

    invalid = []
    alias_count = Hash.new(0)
    aliases.each do |name|
      alias_count[name] += 1
      invalid << name if name !~ %r{\A[\w+-]+\Z}
    end

    duplicates = alias_count.select { |_, count| count > 1 }.keys

    assert_equal [], invalid, "some negarmoji have invalid names"
    assert_equal [], duplicates, "some negarmoji aliases have duplicates"
  end

  test "negarmoji have category" do
    missing = Emoji.all.select { |e| e.category.to_s.empty? }
    assert_equal [], missing.map(&:name), "some negarmoji don't have a category"

    emoji = Emoji.find_by_alias("family_man_woman_girl")
    assert_equal "People & Body", emoji.category

    categories = Emoji.all.map(&:category).uniq.compact
    assert_equal [
                     "Smileys & Emotion",
                     "People & Body",
                     "Animals & Nature",
                     "Food & Drink",
                     "Travel & Places",
                     "Activities",
                     "Objects",
                     "Symbols",
                     "Flags",
                     "Component",
                     "Extras & Openmoji",
                     "Extras & Unicode"
    ], categories
  end

  test "negarmoji have description" do
    missing = Emoji.all.select { |e| e.description.to_s.empty? }
    assert_equal [], missing.map(&:name), "some negarmoji don't have a description"

    emoji = Emoji.find_by_alias("family_man_woman_girl")
    assert_equal "family: man, woman, girl", emoji.description
  end

  test "negarmoji have Unicode version" do
    emoji = Emoji.find_by_alias("family_man_woman_girl")
    assert_equal "6.0", emoji.unicode_version
  end

  test "negarmoji have iOS version" do
    missing = Emoji.all.select { |e| e.ios_version.to_s.empty? }
    assert_equal [], missing.map(&:name), "some negarmoji don't have an iOS version"

    emoji = Emoji.find_by_alias("family_man_woman_girl")
    assert_equal "8.3", emoji.ios_version
  end

  test "no custom emojis" do
    custom = Emoji.all.select(&:custom?)
    assert 0, custom.size
  end

  test "create" do
    emoji = Emoji.create("music") do |char|
      char.add_unicode_alias "\u{266b}"
      char.add_unicode_alias "\u{266a}"
      char.add_tag "notes"
      char.add_tag "eighth"
    end

    begin
      assert_equal emoji, Emoji.all.last
      assert_equal emoji, Emoji.find_by_alias("music")
      assert_equal emoji, Emoji.find_by_unicode("\u{266a}")
      assert_equal emoji, Emoji.find_by_unicode("\u{266b}")

      assert_equal "\u{266b}", emoji.raw
      assert_equal "266b.svg", emoji.image_filename
      assert_equal %w[music], emoji.aliases
      assert_equal %w[notes eighth], emoji.tags
    ensure
      Emoji.all.pop
    end
  end

  test "create with custom filename" do
    emoji = Emoji.create("music") do |char|
      char.image_filename = "some_path/my_emoji.gif"
    end

    begin
      assert_equal "some_path/my_emoji.gif", emoji.image_filename
    ensure
      Emoji.all.pop
    end
  end

  test "create without block" do
    emoji = Emoji.create("music")

    begin
      assert_equal emoji, Emoji.find_by_alias("music")
      assert_equal [], emoji.unicode_aliases
      assert_equal [], emoji.tags
      assert_equal "music.svg", emoji.image_filename
    ensure
      Emoji.all.pop
    end
  end

  test "edit" do
    emoji = Emoji.find_by_alias("weary")

    emoji = Emoji.edit_emoji(emoji) do |char|
      char.add_alias "whining"
      char.add_unicode_alias "\u{1f629}\u{266a}"
      char.add_tag "complaining"
    end

    begin
      assert_equal emoji, Emoji.find_by_alias("weary")
      assert_equal emoji, Emoji.find_by_alias("whining")
      assert_equal emoji, Emoji.find_by_unicode("\u{1f629}")
      assert_equal emoji, Emoji.find_by_unicode("\u{1f629}\u{266a}")

      assert_equal %w[weary whining], emoji.aliases
      assert_includes emoji.tags, "complaining"
    ensure
      emoji.aliases.pop
      emoji.unicode_aliases.pop
      emoji.tags.pop
    end
  end
end
