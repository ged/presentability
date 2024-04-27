# -*- ruby -*-

require 'loggability'


# :include: Presentability.md
module Presentability
	extend Loggability


	# Package version
	VERSION = '0.5.0'

	# Automatically load subordinate components
	autoload :Presenter, 'presentability/presenter'


	# Create a logger used by all Presentability modules
	log_as :presentability


	#
	# Hooks
	#

	### Extension hook -- decorate the including +mod+.
	def self::extended( mod )
		super
		mod.singleton_class.attr_accessor :presenters
		mod.singleton_class.attr_accessor :serializers

		mod.presenters = {}
		mod.serializers = {
			Array => mod.method( :serialize_array ),
			Hash => mod.method( :serialize_hash ),
		}
	end



	#
	# DSL Methods
	#

	### Set up a presentation for the given +entity_class+.
	def presenter_for( entity_class, &block )
		presenter_class = Class.new( Presentability::Presenter )
		presenter_class.module_eval( &block )

		self.presenters[ entity_class ] = presenter_class
	end


	### Set up a rule for how to serialize objects of the given +type+ if there is
	### no presenter declared for it.
	def serializer_for( type, method )
		self.serializers[ type ] = method
	end


	#
	# Presentation Methods
	#

	### Return a representation of the +object+ by applying a declared presentation.
	def present( object, **options )
		representation = self.present_by_class( object, **options ) ||
			self.present_by_classname( object, **options ) ||
			self.serialize( object, **options )

		unless representation
			if object.instance_variables.empty?
				return object
			else
				raise NoMethodError, "no presenter found for %p" % [ object ], caller( 1 )
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


	### Serialize the specified +object+ if a serializer has been declared for it
	### and return the scalar result.
	def serialize( object, ** )
		serializer = self.serializers[ object.class ] ||
			self.serializers[ object.class.name ] or
			return nil
		serializer_proc = serializer.to_proc

		return serializer_proc.call( object )
	end


	### Default serializer for an Array; returns a new array of presented objects.
	def serialize_array( object )
		return object.map do |member|
			self.present( member, unless: :in_collection )
		end
	end


	### Default serializer for a Hash; returns a new Hash of presented keys and values.
	def serialize_hash( object )
		return object.each_with_object( {} ) do |(key, val), newhash|
			p_key = self.present( key, unless: :in_collection )
			p_val = self.present( val, unless: :in_collection )

			newhash[ p_key ] = p_val
		end
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

