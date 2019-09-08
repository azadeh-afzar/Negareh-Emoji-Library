Gem::Specification.new do |s|
  s.name    = "negarmoji"
  s.version = "1"
  s.summary = "Unicode emoji library"
  s.description = "Character information and metadata for Unicode emoji."

  s.required_ruby_version = '> 1.9'

  s.authors  = ["Mohammad Mahdi Bgahbani Pourvahid"]
  s.email    = "MahdiBaghbani@protonmail.com"
  s.homepage = "https://gitlab.com/Azadeh-Afzar/Web-Development/Negareh-Emoji-Library"
  s.licenses = ["GPLv3"]

  s.files = Dir[
    "README.md",
    "LICENSE",
    "db/emoji.json",
    "lib/**/*.rb",
  ]
end
