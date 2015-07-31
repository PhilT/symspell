require 'base64'

Gem::Specification.new do |s|
  s.name        = 'symspell'
  s.version     = '0.0.1'
  s.authors     = 'Phil Thompson'
  s.email       = Base64.decode64("cGhpbEBlbGVjdHJpY3Zpc2lvbnMuY29t\n")
  s.summary     = 'Ruby port of the symetric spell checking algorithm'
  s.homepage    = 'https://github.com/PhilT/symspell'
  s.required_rubygems_version = '>= 2.4.5'

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- spec/*`.split("\n")

  s.require_path = 'lib'
end

