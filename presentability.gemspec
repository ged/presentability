# -*- encoding: utf-8 -*-
# stub: presentability 0.1.0.pre.20220811102015 ruby lib

Gem::Specification.new do |s|
  s.name = "presentability".freeze
  s.version = "0.1.0.pre.20220811102015"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/Presentability", "changelog_uri" => "https://deveiate.org/code/presentability/History_md.html", "documentation_uri" => "https://deveiate.org/code/presentability", "homepage_uri" => "https://hg.sr.ht/~ged/Presentability", "source_uri" => "https://hg.sr.ht/~ged/Presentability" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2022-08-11"
  s.description = "Facade-based presenters with minimal assumptions. This library contains utilities for setting up presenters for data classes for things like web services, logging output, etc.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.files = ["History.md".freeze, "LICENSE.txt".freeze, "README.md".freeze, "lib/presentability.rb".freeze, "lib/presentability/presenter.rb".freeze, "spec/presentability/presenter_spec.rb".freeze, "spec/presentability_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/Presentability".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Facade-based presenters with minimal assumptions.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.18"])
    s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.19"])
    s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
  else
    s.add_dependency(%q<loggability>.freeze, ["~> 0.18"])
    s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.19"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
  end
end
