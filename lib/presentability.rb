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
		presenter_class.instance_eval( &block )

		self.presenters[ entity_class ] = presenter_class
	end


	### Return a representation of the +object+ by applying a declared presentation.
	def present( object )
		representation = self.present_by_class( object )

		return representation
	end


	### Return a representation of the +object+ by applying a presenter declared for its
	### class. Returns +nil+ if no such presenter exists.
	def present_by_class( object )
		presenter_class = self.presenters[ object.class ] or return nil
		presenter = presenter_class.new( object )

		return presenter.apply
	end

end # module Presentability

