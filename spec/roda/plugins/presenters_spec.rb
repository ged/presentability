# -*- ruby -*-

require_relative '../../spec_helper'

require 'roda'
require 'roda/plugins/presenters'


RSpec.describe( Roda::RodaPlugins::Presenters ) do

	let( :app ) { Class.new(Roda) }

	let( :entity_class ) do
		Class.new do
			def self::name
				return 'Acme::Entity'
			end

			def initialize( foo: 1, bar: 'two', baz: :three )
				@foo = foo
				@bar = bar
				@baz = baz
			end

			attr_accessor :foo, :bar, :baz
		end
	end


	it "adds an anonymous presenter collection to including apps" do
		app.plugin( described_class )

		expect( app.presenter_collection ).to be_a( Module )
	end


	it "clones the presenter collection for subclasses" do
		app.plugin( described_class )
		subapp = Class.new( app )

		expect( subapp.presenter_collection ).to be_a( Module )
		expect( app.presenter_collection ).to_not be( subapp.presenter_collection )
	end


	it "allows an existing presenter collection module to be added to including apps" do
		collection = Module.new
		app.plugin( described_class, collection: collection )

		expect( app.presenter_collection ).to be( collection )
	end


	it "allows the use of presenters in application routes" do
		collection = Module.new
		collection.extend( Presentability )
		collection.presenter_for( entity_class ) do
			expose :foo
			expose :bar
		end
		app.plugin( described_class, collection: collection )

		app_instance = app.new( {} )

		result = app_instance.present( entity_class.new )
		expect( result ).to be_a( Hash ).and( include(:foo, :bar) )
		expect( result ).to_not include( :baz )
	end

end

