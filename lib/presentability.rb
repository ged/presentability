# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'


# Facade-based presenter toolkit with minimal assumptions.
#
# ## Basic Usage
#
# Basic usage of Presentability requires two steps: declaring presenters and
# then using them.
#
# ### Declaring Presenters
#
# Presenters are just regular Ruby classes with some convenience methods for
# declaring exposures, but in a lot of cases you'll want to declare them all in
# one place. Presentability offers a mixin that implements a simple DSL for
# declaring presenters and their associations to entity classes, intended to be
# used in a container module:
#
# ```ruby
# require 'presentability'
#
# module Acme::Presenters
#	 extend Presentability
#
#	 presenter_for( Acme::Widget ) do
#		 expose :sku
#		 expose :name
#		 expose :unit_price
#	 end
#
# end
# ```
#
# The block of `presenter_for` is evaluated in the context of a new Presenter
# class, so refer to that documentation for what's possible there.
#
# Sometimes you can't (or don't want to) have to load the entity class to
# declare a presenter for it, so you can also declare it using the class's name:
#
# ```ruby
# presenter_for( 'Acme::Widget' ) do
#	 expose :sku
#	 expose :name
#	 expose :unit_price
# end
# ```
#
# ### Using Presenters
#
# You use presenters by instantiating them with the object they are a facade for
# (the "subject"), and then applying it:
#
# ```ruby
# presenter = Acme::Presenters.present( acme_widget )
# presenter.apply
# # => { :sku => "FF-2237H455", :name => "Throbbing Frobnulator", :unit_price => 299 }
# ```
#
#
module Presentability
	extend Loggability


	# Package version
	VERSION = '0.0.1'


	# Automatically load subordinate components
	autoload :Presenter, 'presentability/presenter'


	# Create a logger used by all Presentability modules
	log_as :presentability


	### Extension hook -- decorate the including +mod+.
	def self::extended( mod )
		super
		mod.singleton_class.attr_accessor :presenters
		mod.presenters = {}
	end



	### Set up a presentation for the given +entity_class+.
	def presenter_for( entity_class, &block )
		presenter_class = Class.new( Presentability::Presenter )
		presenter_class.module_eval( &block )

		self.presenters[ entity_class ] = presenter_class
	end


	### Return a representation of the +object+ by applying a declared presentation.
	def present( object, **options )
		representation = self.present_by_class( object, **options ) ||
			self.present_by_classname( object, **options ) or
			raise NoMethodError, "no presenter found for %p" % [ object ]

		return representation
	end


	#########
	protected
	#########

	### Return a representation of the +object+ by applying a presenter declared for its
	### class. Returns +nil+ if no such presenter exists.
	def present_by_class( object, **presentation_options )
		presenter_class = self.presenters[ object.class ] or return nil
		presenter = presenter_class.new( object, **presentation_options )

		return presenter.apply
	end


	### Return a representation of the +object+ by applying a presenter declared for its
	### class name. Returns +nil+ if no such presenter exists.
	def present_by_classname( object, **presentation_options )
		classname = object.class.name or return nil
		presenter_class = self.presenters[ classname ] or return nil
		presenter = presenter_class.new( object, **presentation_options )

		return presenter.apply
	end

end # module Presentability

