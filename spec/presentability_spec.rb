# -*- ruby -*-
# frozen_string_literal: true

require_relative 'spec_helper'

require 'rspec'
require 'presentability'


RSpec.describe Presentability do

	let( :entity_class ) do
		Class.new do
			def self::name
				return 'Acme::Entity'
			end

			def initialize
				@foo = 1
				@bar = 'two'
				@baz = :three
			end

			attr_accessor :foo, :bar, :baz
		end
	end

	let( :entity_instance ) { entity_class.new }


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

	end

end

