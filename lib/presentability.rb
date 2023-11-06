# -*- ruby -*-

require 'loggability'


# :include: Presentability.md
module Presentability
	extend Loggability


	# Package version
	VERSION = '0.4.0'


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
			self.present_by_classname( object, **options )

		unless representation
			if object.instance_variables.empty?
				return object
			else
				raise NoMethodError, "no presenter found for %p" % [ object ]
			end
		end

		return representation
	end


	### Return an Array of all representations of the members of the
	### +collection+ by applying a declared presentation.
	def present_collection( collection, **options )
		options = options.merge( in_collection: true )
		return collection.map {|object| self.present(object, **options) }
	end


	#########
	protected
	#########

	### Return a representation of the +object+ by applying a presenter declared for its
	### class. Returns +nil+ if no such presenter exists.
	def present_by_class( object, **presentation_options )
		presenter_class = self.presenters[ object.class ] or return nil
		presenter = presenter_class.new( object, **presentation_options )

		return presenter.apply( self )
	end


	### Return a representation of the +object+ by applying a presenter declared for its
	### class name. Returns +nil+ if no such presenter exists.
	def present_by_classname( object, **presentation_options )
		classname = object.class.name or return nil
		presenter_class = self.presenters[ classname ] or return nil
		presenter = presenter_class.new( object, **presentation_options )

		return presenter.apply( self )
	end

end # module Presentability

