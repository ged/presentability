# -*- ruby -*-
# frozen_string_literal: true

require_relative 'spec_helper'

require 'rspec'
require 'presentability'


RSpec.describe Presentability do

	let( :entity_class ) do
		Class.new do
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

		subject do
			mod = Module.new
			mod.extend( described_class )
		end


		it "can define a presenter for an explicit class" do
			subject.presenter_for( entity_class ) do
				expose :foo
				expose :bar
			end

			expect( subject.present(entity_instance) ).to eq({ foo: 1, bar: 'two' })
		end


	end

end

