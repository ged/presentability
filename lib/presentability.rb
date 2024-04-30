# -*- ruby -*-

require 'loggability'


#
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
#     require 'presentability'
#
#     module Acme::Presenters
#       extend Presentability
#
#       presenter_for( Acme::Widget ) do
#           expose :sku
#           expose :name
#           expose :unit_price
#       end
#
#     end
#
# The block of `presenter_for` is evaluated in the context of a new Presenter
# class, so refer to that documentation for what's possible there.
#
# Sometimes you can't (or don't want to) have to load the entity class to
# declare a presenter for it, so you can also declare it using the class's name:
#
#     presenter_for( 'Acme::Widget' ) do
#         expose :sku
#         expose :name
#         expose :unit_price
#     end
#
#
# ### Using Presenters
#
# You use presenters by instantiating them with the object they are a facade for
# (the "subject"), and then applying it:
#
#     acme_widget = Acme::Widget.new(
#         sku: "FF-2237H455",
#         name: "Throbbing Frobnulator",
#         unit_price: 299,
#         inventory_count: 301,
#         wholesale_cost: 39
#     )
#     presentation = Acme::Presenters.present( acme_widget )
#     # => { :sku => "FF-2237H455", :name => "Throbbing Frobnulator", :unit_price => 299 }
#
# If you want to present a collection of objects as a collection, you can apply
# presenters to the collection instead:
#
#     widgets_in_stock = Acme::Widget.where { inventory_count > 0 }
#     collection_presentation = Acme::Presenters.present_collection( widgets_in_stock )
#     # => [ {:sku => "FF-2237H455", [...]}, {:sku => "FF-2237H460", [...]}, [...] ]
#
# The collection can be anything that is `Enumerable`.
#
#
# ### Presentation Options
#
# Sometimes you want a bit more flexibility in what you present, allowing a single
# uniform presenter to be used in multiple use cases. To facilitate this, you can pass
# an options keyword hash to `#present`:
#
#     presenter_for( 'Acme::Widget' ) do
#         expose :sku
#         expose :name
#         expose :unit_price
#
#         # Only expose the wholesale cost if presented via an internal API
#         expose :wholesale_cost, if: :internal_api
#     end
#
#     acme_widget = Acme::Widget.new(
#         sku: "FF-2237H455",
#         name: "Throbbing Frobnulator",
#         unit_price: 299,
#         inventory_count: 301,
#         wholesale_cost: 39
#     )
#
#     # External API remains unchanged:
#     presentation = Acme::Presenters.present( acme_widget )
#     # => { :sku => "FF-2237H455", :name => "Throbbing Frobnulator", :unit_price => 299 }
#
#     # But when run from an internal service:
#     internal_presentation = Acme::Presenters.present( acme_widget, internal_api: true )
#     # => { :sku => "FF-2237H455", :name => "Throbbing Frobnulator", :unit_price => 299,
#     #      :wholesale_cost => 39 }
#
# There are some options that are set for you:
#
# <dl>
# <td><code>:in_collection</code></td>
# <dd>Set if the current object is being presented as part of a collection.</dd>
# </dl>
#
module Presentability
	extend Loggability


	# Package version
	VERSION = '0.6.0'

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
			self.present( member, in_collection: true )
		end
	end


	### Default serializer for a Hash; returns a new Hash of presented keys and values.
	def serialize_hash( object )
		return object.each_with_object( {} ) do |(key, val), newhash|
			p_key = self.present( key, in_collection: true )
			p_val = self.present( val, in_collection: true )

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

