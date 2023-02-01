# -*- ruby -*-

if ENV['COVERAGE']
	require 'simplecov'
	SimpleCov.start do
		add_filter 'spec/'
		enable_coverage :branch
		primary_coverage :branch
	end
end

require 'rspec'
require 'i18n'
require 'faker'

Faker::Config.locale = 'en'
I18n.reload!

require 'loggability/spechelpers'


### Mock with RSpec
RSpec.configure do |config|
	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	config.disable_monkey_patching!
	config.example_status_persistence_file_path = "spec/.status"
	config.filter_run :focus
	config.filter_run_when_matching :focus
	config.order = :random
	config.profile_examples = 5
	config.run_all_when_everything_filtered = true
	config.shared_context_metadata_behavior = :apply_to_host_groups
	# config.warnings = true

	config.include( Loggability::SpecHelpers )
end


