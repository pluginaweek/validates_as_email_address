$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'validates_as_email_address/version'

Gem::Specification.new do |s|
  s.name              = "validates_as_email_address"
  s.version           = ValidatesAsEmailAddress::VERSION
  s.authors           = ["Aaron Pfeifer"]
  s.email             = "aaron@pluginaweek.org"
  s.homepage          = "http://www.pluginaweek.org"
  s.description       = "Adds support for validating the format/length of email addresses in ActiveRecord"
  s.summary           = "Email address validation in ActiveRecord"
  s.require_paths     = ["lib"]
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- test/*`.split("\n")
  s.rdoc_options      = %w(--line-numbers --inline-source --title validates_as_email_address --main README.rdoc)
  s.extra_rdoc_files  = %w(README.rdoc CHANGELOG.rdoc LICENSE)
end
