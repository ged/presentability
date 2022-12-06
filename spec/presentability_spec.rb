# -*- ruby -*-
# frozen_string_literal: true

require_relative 'spec_helper'

require 'faker'
require 'rspec'
require 'presentability'


RSpec.describe Presentability do

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

	let( :other_entity_class ) do
		Class.new do
			def self::name
				return 'Acme::User'
			end

			def initialize( firstname, lastname, email, password )
				@firstname = firstname
				@lastname = lastname
				@email = email
				@password = password
			end

			attr_accessor :firstname, :lastname, :email, :password
		end
	end

	let( :entity_instance ) { entity_class.new }
	let( :other_entity_instance ) { entity_class.new }


	describe "an extended module" do

		let( :extended_module ) do
			mod = Module.new
			mod.extend( described_class )
		end


		it "can define a presenter for an explicit class" do
			extended_module.presenter_for( entity_class ) do
				expose :foo
				expose :bar
			end

			expect( extended_module.present(entity_instance) ).to eq({ foo: 1, bar: 'two' })
		end


		it "can define a presenter for a class name" do
			extended_module.presenter_for( 'Acme::Entity' ) do
				expose :foo
				expose :bar
			end

			expect( extended_module.present(entity_instance) ).to eq({ foo: 1, bar: 'two' })
		end


		it "can effect more complex exposures be declaring presenter methods" do
			extended_module.presenter_for( entity_class ) do
				expose :foo
				expose :bar
				expose :id

				def id
					self.subject.object_id
				end
			end

			expect( extended_module.present(entity_instance) ).
				to eq({ foo: 1, bar: 'two', id: entity_instance.object_id })
		end


		it "can be made conditional on an option being set" do
			extended_module.presenter_for( entity_class ) do
				expose :foo
				expose :bar, if: :include_bar
			end

			result1 = extended_module.present( entity_instance )
			result2 = extended_module.present( entity_instance, include_bar: true )

			expect( result1 ).to eq({ foo: 1 })
			expect( result2 ).to eq({ foo: 1, bar: 'two' })
		end


		it "errors usefully if asked to present an object it knows nothing about" do
			expect {
				extended_module.present( entity_instance )
			}.to raise_error( NoMethodError, /no presenter found/i )
		end


		it "errors usefully if asked to expose an attribute that doesn't exist" do
			extended_module.presenter_for( entity_class ) do
				expose :id
			end

			expect {
				extended_module.present( entity_instance )
			}.to raise_error( NoMethodError, /can't expose :id -- no such attribute exists/i )
		end


		describe "collection handling" do

			it "can present a collection" do
				extended_module.presenter_for( entity_class ) do
					expose :foo
					expose :bar
				end
				collection = 5.times.map do
					entity_class.new( foo: rand(100) )
				end

				results = extended_module.present_collection( collection )

				expect( results ).to have_attributes( length: 5 )
				results.each do |representation|
					expect( representation ).to include( :foo, :bar )
					expect( representation ).to_not include( :baz )
				end
			end


			it "can present a mixed collection" do
				extended_module.presenter_for( entity_class ) do
					expose :foo
					expose :bar
				end
				extended_module.presenter_for( other_entity_class ) do
					expose :firstname
					expose :lastname
					expose :email
				end

				collection = 5.times.flat_map do
					[
						entity_class.new( foo: rand(100) ),
						other_entity_class.new(
							Faker::Name.first_name,
							Faker::Name.last_name,
							Faker::Internet.email,
							Faker::Internet.password
						)
					]
				end

				results = extended_module.present_collection( collection )

				expect( results ).to have_attributes( length: 10 )
				results.each do |representation|
					expect( representation ).to include( :foo, :bar ).
						or( include(:firstname, :lastname, :email) )
					expect( representation ).to_not include( :baz )
					expect( representation ).to_not include( :password )
				end
			end


			it "passes options to the individual presenters" do
				extended_module.presenter_for( entity_class ) do
					expose :foo
					expose :bar, if: :include_bar
				end
				collection = 5.times.map do
					entity_class.new( foo: rand(100) )
				end

				results = extended_module.present_collection( collection )
				results.each do |representation|
					expect( representation ).to include( :foo )
					expect( representation ).to_not include( :bar, :baz )
				end

				results = extended_module.present_collection( collection, include_bar: true )
				results.each do |representation|
					expect( representation ).to include( :foo, :bar )
					expect( representation ).to_not include( :baz )
				end
			end

		end

	end

end

