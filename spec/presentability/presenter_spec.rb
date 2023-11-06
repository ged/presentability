# -*- ruby -*-

require_relative '../spec_helper'

require 'ostruct'
require 'presentability/presenter'


RSpec.describe( Presentability::Presenter ) do

	let( :presenter_subject ) do
		OpenStruct.new(
			country: 'Philippines',
			export: 'Copper',
			flower: 'Sampaguita',
			cities: ['Quezon City', 'Cagayan de Oro', 'Roxas']
		)
	end

	let( :presenters ) do
		mod = Module.new
		mod.extend( Presentability )
		return mod
	end


	it "can't be instantiated directly" do
		expect {
			described_class.new( presenter_subject )
		}.to raise_error( NoMethodError, /private method `new'/i )
	end


	describe "concrete subclass" do

		let( :subclass ) { Class.new(described_class) }


		it "can be created with just a subject" do
			presenter = subclass.new( presenter_subject )
			expect( presenter.apply(presenters) ).to eq( {} )
		end


		it "can expose an attribute" do
			subclass.expose( :country )
			presenter = subclass.new( presenter_subject )

			expect( presenter.apply(presenters) ).to eq({ country: 'Philippines' })
		end


		it "can expose attributes conditionally" do
			subclass.expose( :country )
			subclass.expose( :export, if: :financial )
			subclass.expose( :flower, unless: :financial )

			financial_presenter = subclass.new( presenter_subject, financial: true )
			cultural_presenter = subclass.new( presenter_subject, financial: false )

			expect( financial_presenter.apply(presenters) ).
				to eq({ country: 'Philippines', export: 'Copper' })
			expect( cultural_presenter.apply(presenters) ).
				to eq({ country: 'Philippines', flower: 'Sampaguita' })
		end


		it "doesn't skip exposures that are unconditional" do
			subclass.expose( :country )

			presenter = subclass.new( presenter_subject )

			expect( presenter.skip_exposure?(:country) ).to be_falsey
		end


		it "skips exposures whose conditions are unmet" do
			subclass.expose( :country )
			subclass.expose( :export, if: :financial )
			subclass.expose( :flower, unless: :financial )

			presenter = subclass.new( presenter_subject, financial: true )

			expect( presenter.skip_exposure?(:export) ).to be_falsey
			expect( presenter.skip_exposure?(:flower) ).to be_truthy
		end


		it "skips exposures that don't exist" do
			subclass.expose( :country )
			subclass.expose( :export, if: :financial )
			subclass.expose( :flower, unless: :financial )

			presenter = subclass.new( presenter_subject )

			expect( presenter.skip_exposure?(:bus_schedule) ).to be_truthy
		end


		it "can expose an attribute as a collection" do
			subclass.expose( :country )
			subclass.expose_collection( :cities )

			expect( subclass.exposures[:cities] ).to include( unless: :in_collection )
		end


		it "has useful #inspect output" do
			presenter = subclass.new( presenter_subject )
			expect( presenter.inspect ).to match( /Presentability::Presenter\S+ for /i )
		end

	end

end

