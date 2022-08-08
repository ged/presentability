# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'


# Facade-based presenters with minimal assumptions.
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

