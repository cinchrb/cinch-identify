Gem::Specification.new do |s|
  s.name = 'cinch-identify'
  s.version = '1.5.0'
  s.summary = 'A plugin allowing Cinch bots to automatically identify with services.'
  s.description = 'A plugin allowing Cinch bots to automatically identify with services. Supported are NickServ, QuakeNet and KreyNet.'
  s.authors = ['Dominik Honnef']
  s.email = ['dominikh@fork-bomb.org']
  s.homepage = 'http://rubydoc.info/github/cinchrb/cinch-identify'
  s.required_ruby_version = '>= 1.9.1'
  s.files = Dir['LICENSE', 'README.md', '{lib,examples}/**/*']
  s.add_dependency("cinch", "~> 2.0")
end
