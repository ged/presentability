# -*- encoding: utf-8 -*-
# stub: presentability 0.7.0.pre.20240429234026 ruby lib

Gem::Specification.new do |s|
  s.name = "presentability".freeze
  s.version = "0.7.0.pre.20240429234026".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/Presentability", "changelog_uri" => "https://deveiate.org/code/presentability/History_md.html", "documentation_uri" => "https://deveiate.org/code/presentability", "homepage_uri" => "https://hg.sr.ht/~ged/Presentability", "source_uri" => "https://hg.sr.ht/~ged/Presentability" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2024-04-29"
  s.description = "Facade-based presenters with minimal assumptions. This library contains utilities for setting up presenters for data classes for things like web services, logging output, etc.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.files = ["GettingStarted.md".freeze, "History.md".freeze, "LICENSE.txt".freeze, "README.md".freeze, "lib/presentability.rb".freeze, "lib/presentability/presenter.rb".freeze, "lib/roda/plugins/presenters.rb".freeze, "spec/presentability/presenter_spec.rb".freeze, "spec/presentability_spec.rb".freeze, "spec/roda/plugins/presenters_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/Presentability".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.5.3".freeze
  s.summary = "Facade-based presenters with minimal assumptions.".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.18".freeze])
  s.add_development_dependency(%q<faker>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<roda>.freeze, ["~> 3.79".freeze])
  s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.21".freeze])
  s.add_development_dependency(%q<rdoc-generator-sixfish>.freeze, ["~> 0.2".freeze])
end
