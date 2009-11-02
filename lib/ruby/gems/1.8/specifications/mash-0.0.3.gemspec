# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mash}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2008-04-19}
  s.description = %q{Mash is an extended Hash that gives simple pseudo-object functionality that can be built from hashes and easily extended. It is designed to be used in RESTful API libraries to provide easy object-like access  to JSON and XML parsed hashes.}
  s.email = ["michael@intridea.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/mash.rb", "spec/mash_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/mbleigh/mash}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mash-hash}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Mash is an extended Hash that gives simple pseudo-object functionality that can be built from hashes and easily extended}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hoe>, [">= 1.5.1"])
    else
      s.add_dependency(%q<hoe>, [">= 1.5.1"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.5.1"])
  end
end
