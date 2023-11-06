# -*- encoding: utf-8 -*-
# stub: presentability 0.6.0.pre.20231106082854 ruby lib

Gem::Specification.new do |s|
  s.name = "presentability".freeze
  s.version = "0.6.0.pre.20231106082854".freeze

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/Presentability", "changelog_uri" => "https://deveiate.org/code/presentability/History_md.html", "documentation_uri" => "https://deveiate.org/code/presentability", "homepage_uri" => "https://hg.sr.ht/~ged/Presentability", "source_uri" => "https://hg.sr.ht/~ged/Presentability" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2023-11-06"
  s.description = "Facade-based presenters with minimal assumptions. This library contains utilities for setting up presenters for data classes for things like web services, logging output, etc.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.files = ["History.md".freeze, "LICENSE.txt".freeze, "Presentability.md".freeze, "Presenter.md".freeze, "README.md".freeze, "lib/presentability.rb".freeze, "lib/presentability/presenter.rb".freeze, "spec/presentability/presenter_spec.rb".freeze, "spec/presentability_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/Presentability".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.4.21".freeze
  s.summary = "Facade-based presenters with minimal assumptions.".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.18".freeze])
  s.add_development_dependency(%q<faker>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.21".freeze])
  s.add_development_dependency(%q<rdoc-generator-sixfish>.freeze, ["~> 0.2".freeze])
end
