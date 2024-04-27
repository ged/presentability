# -*- ruby -*-

require_relative 'spec_helper'

require 'faker'
require 'rspec'
require 'presentability'


RSpec.describe Presentability do

	let( :entity_class ) do
		Class.new do
			set_temporary_name 'Acme::Entity (Testing Class)'

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
			set_temporary_name 'Acme::User (Testing Class)'

			def initialize( firstname, lastname, email, password )
				@firstname = firstname
				@lastname = lastname
				@email = email
				@password = password
				@is_admin = false
			end

			attr_accessor :firstname, :lastname, :email, :password, :is_admin
		end
	end

	let( :complex_entity_class ) do
		Class.new do
			set_temporary_name 'Acme::Pair (Testing Class)'

			def initialize( user:, entity:, overridden: false, locked: true )
				@user = user
				@entity = entity
				@overridden = overridden
				@locked = locked
			end

			attr_accessor :user, :entity, :overridden, :locked
		end
	end

	let( :entity_instance ) { entity_class.new }
	let( :other_entity_instance ) do
		other_entity_class.new(
			Faker::Name.first_name,
			Faker::Name.last_name,
			Faker::Internet.email,
			Faker::Internet.password
		)
	end
	let( :complex_entity_instance ) do
		complex_entity_class.new( user: other_entity_instance, entity: entity_instance )
	end


	describe "when used to extend a module" do

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
			extended_module.presenter_for( entity_class.name ) do
				expose :foo
				expose :bar
			end

			expect( extended_module.present(entity_instance) ).to eq({ foo: 1, bar: 'two' })
		end


		it "can define more complex exposures by declaring presenter methods" do
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


		it "calls an exposure's block if it has one" do
			extended_module.presenter_for( entity_class ) do
				expose :foo
				expose :bar
				expose :id do
					self.subject.object_id
				end
			end

			expect( extended_module.present(entity_instance) ).
				to eq({ foo: 1, bar: 'two', id: entity_instance.object_id })
		end


		it "exposes `false' values correctly" do
			extended_module.presenter_for( other_entity_class ) do
				expose :firstname
				expose :lastname
				expose :email
				expose :is_admin
			end

			other_entity_instance.is_admin = false

			expect( extended_module.present(other_entity_instance) ).to eq({
				firstname: other_entity_instance.firstname,
				lastname: other_entity_instance.lastname,
				email: other_entity_instance.email,
				is_admin: false
			})
		end


		it "exposes `nil' values correctly" do
			extended_module.presenter_for( other_entity_class ) do
				expose :firstname
				expose :lastname
				expose :email
			end

			other_entity_instance.email = nil

			expect( extended_module.present(other_entity_instance) ).to eq({
				firstname: other_entity_instance.firstname,
				lastname: other_entity_instance.lastname,
				email: nil
			})
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


		it "doesn't try to present objects with no instance variables by default" do
			object = 'a string'
			expect( extended_module.present(object) ).to be( object )

			object = 8
			expect( extended_module.present(object) ).to be( object )

			object = :a_symbol
			expect( extended_module.present(object) ).to be( object )

			object = Time.now
			expect( extended_module.present(object) ).to be( object )

			object = %[an array of strings]
			expect( extended_module.present(object) ).to be( object )

			object = Object.new
			expect( extended_module.present(object) ).to be( object )
		end


		it "allows presenters to be defined for objects with no instance variables" do
			extended_module.presenter_for( Time ) do
				expose :sec
				expose :usec
			end

			object = Time.at( 1699287281.336554 )

			expect( extended_module.present(object) ).to eq({
				sec: object.sec,
				usec: object.usec
			})
		end


		describe 'serialization' do

			it "presents each element for Arrays by default" do
				extended_module.presenter_for( entity_class ) do
					expose :foo
				end

				array = 5.times.map { entity_class.new }

				result = extended_module.present( array )

				expect( result ).to eq( [{foo: 1}] * 5 )
			end


			it "presents each value for Hashes by default" do
				extended_module.presenter_for( entity_class ) do
					expose :foo
				end

				hash = { user1: entity_instance(), user2: entity_instance() }

				result = extended_module.present( hash )

				expect( result ).to eq({
					user1: {foo: 1}, user2: {foo: 1}
				})
			end


			it "presents each key for Hashes by default too" do
				extended_module.presenter_for( entity_class ) do
					expose :id do
						self.subject.object_id
					end
				end

				key1 = entity_instance()
				key2 = entity_instance()
				hash = { key1 => 'user1', key2 => 'user2' }

				result = extended_module.present( hash )

				expect( result ).to eq({
					{id: key1.object_id} => 'user1',
					{id: key2.object_id} => 'user2'
				})
			end


			it "can be defined by class for objects that have a simple presentation" do
				extended_module.serializer_for( IPAddr, :to_s )

				object = IPAddr.new( '127.0.0.1/24' )

				expect( extended_module.present(object) ).to eq( '127.0.0.0' )
			end


			it "can be defined by class name for objects that have a simple presentation" do
				extended_module.serializer_for( 'IPAddr', :to_s )

				object = IPAddr.new( '127.0.0.1/24' )

				expect( extended_module.present(object) ).to eq( '127.0.0.0' )
			end

		end


		it "errors usefully if asked to present an object it knows nothing about" do
			expect {
				extended_module.present( entity_instance )
			}.to raise_error( NoMethodError, /no presenter found/i ) do |err|
				expect( err.backtrace.first ).to match( /#{Regexp.escape(__FILE__)}/ )
			end
		end


		it "errors usefully if asked to expose an attribute that doesn't exist" do
			extended_module.presenter_for( entity_class ) do
				expose :id
			end

			expect {
				extended_module.present( entity_instance )
			}.to raise_error( NoMethodError, /undefined method `id'/i )
		end


		it "can alias a field to a different name" do
			extended_module.presenter_for( entity_class ) do
				expose :foo, as: :bar
			end

			expect( extended_module.present(entity_instance) ).to eq({ bar: 1 })
		end


		it "doesn't error when aliasing a field to itself" do
			extended_module.presenter_for( entity_class ) do
				expose :foo, as: :foo
				expose :bar, as: :floom
			end

			expect( extended_module.present(entity_instance) ).to eq({ foo: 1, floom: 'two' })
		end


		it "raises if an alias clobbers another field" do
			expect {
				extended_module.presenter_for( entity_class ) do
					expose :foo
					expose :bar, as: :foo
				end
			}.to raise_error( ScriptError, /alias :foo collides with another exposure/i )
		end


		describe "and used to present a collection" do

			it "handles a homogeneous collection" do
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


			it "handles a heterogeneous collection" do
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


			it "sets the :in_collection option to allow for eliding attributes" do
				extended_module.presenter_for( entity_class ) do
					expose :foo
					expose :bar, unless: :in_collection
					expose :baz
				end

				results = extended_module.present_collection( [entity_instance] )

				expect( results.first ).to include( :foo, :baz )
				expect( results.first ).not_to include( :bar )

				result = extended_module.present( entity_instance )

				expect( result ).to include( :foo, :bar, :baz )
			end

		end


		describe "and used to present a complex object" do

			it "uses registered presenters for sub-objects" do
				extended_module.presenter_for( entity_class ) do
					expose :foo
					expose :bar
				end
				extended_module.presenter_for( other_entity_class ) do
					expose :firstname
					expose :lastname
					expose :email
				end
				extended_module.presenter_for( complex_entity_class ) do
					expose :user
					expose :entity
					expose :locked
				end

				result = extended_module.present( complex_entity_instance )

				expect( result ).to eq({
					user: {
						firstname: other_entity_instance.firstname,
						lastname: other_entity_instance.lastname,
						email: other_entity_instance.email,
					},
					entity: {
						foo: entity_instance.foo,
						bar: entity_instance.bar
					},
					locked: complex_entity_instance.locked,
				})
			end

		end

	end

end

