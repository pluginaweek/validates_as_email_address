# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{validates_as_email_address}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Pfeifer"]
  s.date = %q{2009-06-08}
  s.description = %q{Adds support for validating the format/length of email addresses in ActiveRecord}
  s.email = %q{aaron@pluginaweek.org}
  s.files = ["lib/validates_as_email_address.rb", "lib/validates_as_email_address", "lib/validates_as_email_address/locale.rb", "lib/validates_as_email_address/rfc_1035.rb", "lib/validates_as_email_address/rfc_822.rb", "test/unit", "test/unit/validates_as_email_address_test.rb", "test/factory.rb", "test/app_root", "test/app_root/app", "test/app_root/app/models", "test/app_root/app/models/user.rb", "test/app_root/db", "test/app_root/db/migrate", "test/app_root/db/migrate/001_create_users.rb", "test/test_helper.rb", "CHANGELOG.rdoc", "init.rb", "LICENSE", "Rakefile", "README.rdoc"]
  s.has_rdoc = true
  s.homepage = %q{http://www.pluginaweek.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pluginaweek}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Adds support for validating the format/length of email addresses in ActiveRecord}
  s.test_files = ["test/unit/validates_as_email_address_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
