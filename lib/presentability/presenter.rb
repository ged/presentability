# -*- ruby -*-

require 'loggability'

require 'presentability' unless defined?( Presentability )

# :include: Presenter.md
class Presentability::Presenter
	extend Loggability


	# The exposure options used by every exposure unless overridden
	DEFAULT_EXPOSURE_OPTIONS = {}.freeze


	# Loggability API; use Presentability's logger
	log_to :presentability


	# This is an abstract class; disallow instantiation
	private_class_method :new


	### Enable instantiation by subclasses.
	def self::inherited( subclass )
		super
		subclass.public_class_method( :new )
		subclass.exposures = {}
	end


	##
	# :singleton-method: exposures
	# The Hash of exposures declared by this class
	singleton_class.attr_accessor :exposures


	### Set up an exposure that will delegate to the attribute of the subject with
	### the given +name+.
	def self::expose( name, **options, &block )
		name = name.to_sym
		options = DEFAULT_EXPOSURE_OPTIONS.merge( options )

		self.define_method( name, &block ) if block

		unless self.instance_methods( true ).include?( name )
			method_body = self.generate_expose_method( name, **options )
			define_method( name, &method_body )
		end

		if (exposure_alias = options[:as]) && self.exposures.key?( exposure_alias )
			raise ScriptError, "alias %p collides with another exposure" % [ exposure_alias ]
		end

		self.log.debug "Setting up exposure %p, options = %p" % [ name, options ]
		self.exposures[ name ] = options
	end


	### Set up an exposure of a collection with the given +name+. This means it will
	### have the :in_collection option set by default.
	def self::expose_collection( name, **options, &block )
		options = options.merge( unless: :in_collection )
		self.expose( name, **options, &block )
	end


	### Generate the body an exposure method that delegates to a method with the
	### same +name+ on its subject.
	def self::generate_expose_method( name, **options )
		self.log.debug "Generating a default delegation exposure method for %p" % [ name ]
		return lambda do
			return self.subject.send( __method__ )
		end
	end


	### Method definition hook -- hook up new methods with the same name as an exposure
	### to its :call option.
	def self::method_added( method_name )
		super

		return unless self.exposures

		if self.exposures.key?( method_name )
			self.log.debug "Exposing %p via a new presenter method." % [ method_name ]
			self.exposures[ method_name ][ :call ] = self.instance_method( method_name )
		end
	end


	#
	# Instance methods
	#

	### Create a new Presenter for the given +subject+.
	def initialize( subject, options={} )
		@subject = subject
		@options = options
	end


	######
	public
	######

	##
	# The subject of the presenter, the object that is delegated to when
	# building the representation.
	attr_reader :subject

	##
	# The presentation options
	attr_reader :options


	### Apply the exposures to the subject and return the result.
	def apply( presenters )
		result = self.empty_representation

		self.class.exposures.each do |name, exposure_options|
			next if self.skip_exposure?( name )
			value = self.method( name ).call
			value = presenters.present( value, **exposure_options ) unless
				value.is_a?( result.class )
			key = exposure_options.key?( :as ) ? exposure_options[:as] : name
			result[ key.to_sym ] = value
		end

		return result
	end


	### Returns +true+ if the exposure with the specified +name+ should be skipped
	### for the current #subject and #options.
	def skip_exposure?( name )
		exposure_options = self.class.exposures[ name ] or return true

		return (exposure_options[:if] && !self.options[ exposure_options[:if] ]) ||
			(exposure_options[:unless] && self.options[ exposure_options[:unless] ])
	end


	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		return "#<Presentability::Presenter:%#0x for %p>" % [ self.object_id / 2, self.subject ]
	end


	#########
	protected
	#########

	### Return a new instance of whatever object type will be used to represent the
	### subject.
	def empty_representation
		return {}
	end


end # class Presentability::Presenter

