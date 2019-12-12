<p align="center">
  <br>
  <a href="#">
    <img src="logo.svg" width="100" alt="Negareh Emoji Library"/>
  </a>
</p>

<h1 align="center">Negareh Emoji Library</h1>
<h3 align="center">Character information and metadata for Unicode emoji.</h3>

<p align="center">
  <a title="Open Source" href="https://opensource.com/resources/what-open-source" target="_blank">
    <img src="https://img.shields.io/badge/Open%20Source-Forever-brightgreen?logo=open-source-initiative&style=flat-square" alt="Open Source">
  </a>
  <a title="License: GPLv3" href="https://www.opensource.org/licenses/GPL-3.0" target="_blank">
    <img src="https://img.shields.io/github/license/azadeh-afzar/Negareh-Emoji-Library?logo=gnu&style=flat-square" alt="License: GPLv3">
  </a>
  <a title="Language counter" href="#" target="_blank">
    <img src="https://img.shields.io/github/languages/count/azadeh-afzar/Negareh-Emoji-Library?logo=gitlab&style=flat-square" alt="Language counter">
  </a>
  <a title="Top language" href="#" target="_blank">
    <img src="https://img.shields.io/github/languages/top/azadeh-afzar/Negareh-Emoji-Library?logo=gitlab&style=flat-square" alt="Top language">
  </a>
  
  <br>
  
  <a title="Code Quality: Codefactor.io" href="https://www.codefactor.io/repository/github/azadeh-afzar/Negareh-Emoji-Library" target="_blank">
    <img src="https://www.codefactor.io/repository/github/azadeh-afzar/Negareh-Emoji-Library/badge?style=flat-square" alt="CodeFactor"/>
  </a>
  <a title="Code Quality: CodeClimate.com" href="https://codeclimate.com/github/azadeh-afzar/Negareh-Emoji-Library/maintainability" target="_blank">
    <img src="https://img.shields.io/codeclimate/maintainability/azadeh-afzar/Negareh-Emoji-Library?logo=code-climate&style=flat-square" alt="CodeClimate rating"/>
  </a>
  <a title="Code Technical Debt: CodeClimate.com" href="https://codeclimate.com/github/azadeh-afzar/Negareh-Emoji-Library/maintainability" target="_blank">
    <img src="https://img.shields.io/codeclimate/tech-debt/azadeh-afzar/Negareh-Emoji-Library?logo=code-climate&style=flat-square" alt="CodeClimate technical debt"/>
  </a>
  <a title="Code Issues: CodeClimate.com" href="https://codeclimate.com/github/azadeh-afzar/Negareh-Emoji-Library/maintainability" target="_blank">
    <img src="https://img.shields.io/codeclimate/issues/azadeh-afzar/Negareh-Emoji-Library?logo=code-climate&style=flat-square" alt="CodeClimate issues"/>
  </a>
  
  <br>

  <a title="GitLab: pipeline status" href="https://gitlab.com/Azadeh-Afzar/Web-Development/Negareh-Emoji-Library/commits/master" target="_blank">
    <img src="https://img.shields.io/gitlab/pipeline/Web-Development/Negareh-Emoji-Library?gitlab_url=https%3A%2F%2Fgitlab.com%2FAzadeh-Afzar&logo=gitlab&style=flat-square"  alt="pipeline status" />
  </a>
  <a title="Test Coverage: CodeClimate.com" href="https://codeclimate.com/github/azadeh-afzar/Negareh-Emoji-Library" target="_blank">
    <img src="https://img.shields.io/codeclimate/coverage/azadeh-afzar/Negareh-Emoji-Library?logo=code-climate&style=flat-square" alt="CodeClimate"/>
  </a>
  
  <br>

  <a title="Gem Version" href="https://rubygems.org/gems/negarmoji">
    <img src="https://img.shields.io/gem/v/negarmoji?color=red&label=Negareh%20Emoji%20Library&logo=rubygems&style=flat-square" alt="Gem Version">
  </a>
</p>

> If you are viewing this repository on GitHub, this GitHub repository is a mirror of the Negareh Emoji Library,
> the main repository is served on 
><a href="https://gitlab.com/Azadeh-Afzar/Web-Development/Negareh-Emoji-Library">GitLab</a>, all developments and
>discussions, issue tracking and merge requests take place in GitLab.  

> This project is a fork of <a href="https://github.com/github/jemoji">Gemoji</a>. 

negarmoji
======

This library contains character information about native emojis.


Installation
------------

Add `negarmoji` to your Gemfile.

``` ruby
gem 'negarmoji'
```


Example Rails Helper
--------------------

This would allow emojifying content such as: `it's raining :cat:s and :dog:s!`

See the [Emoji cheat sheet](http://www.emoji-cheat-sheet.com) for more examples.

```ruby
module EmojiHelper
  def emojify(content)
    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %(<img alt="#$1" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      else
        match
      end
    end.html_safe if content.present?
  end
end
```

Unicode mapping
---------------

Translate emoji names to unicode and vice versa.

```ruby
>> Emoji.find_by_alias("cat").raw
=> "🐱"  # Don't see a cat? That's U+1F431.

>> Emoji.find_by_unicode("\u{1f431}").name
=> "cat"
```

Adding new emoji
----------------

You can add new emoji characters to the `Emoji.all` list:

```ruby
emoji = Emoji.create("music") do |char|
  char.add_alias "song"
  char.add_unicode_alias "\u{266b}"
  char.add_tag "notes"
end

emoji.name #=> "music"
emoji.raw  #=> "♫"
emoji.image_filename #=> "unicode/266b.png"

# Creating custom emoji (no Unicode aliases):
emoji = Emoji.create("music") do |char|
  char.add_tag "notes"
end

emoji.custom? #=> true
emoji.image_filename #=> "music.png"
```

As you create new emoji, you must ensure that you also create and put the images
they reference by their `image_filename` to your assets directory.

You can customize `image_filename` with:

```ruby
emoji = Emoji.create("music") do |char|
  char.image_filename = "subdirectory/my_emoji.gif"
end
```

For existing emojis, you can edit the list of aliases or add new tags in an edit block:

```ruby
emoji = Emoji.find_by_alias "musical_note"

Emoji.edit_emoji(emoji) do |char|
  char.add_alias "music"
  char.add_unicode_alias "\u{266b}"
  char.add_tag "notes"
end

Emoji.find_by_alias "music"       #=> emoji
Emoji.find_by_unicode "\u{266b}"  #=> emoji
```
## Contribution

If you want to contribute to this project, please read [CONTRIBUTING](CONTRIBUTING.md).

## Code of Conduct

Visit the [Code of Conduct](CODE_OF_CONDUCT.md).

## Roadmap

Visit the [Roadmap](ROADMAP.md) to keep track of which features we are currently
working on.

## License

Licensed under the [GPLv3](LICENSE).

## Attribution
2. This project is a fork of [Gemoji](https://github.com/github/gemoji). License: MIT
