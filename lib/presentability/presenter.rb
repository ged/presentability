# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'

require 'presentability' unless defined?( Presentability )


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
	# The Hash of exposures declared by this class
	singleton_class.attr_accessor :exposures


	### Set up an exposure that will delegate to the attribute of the subject with
	### the given +name+.
	def self::expose( name, options={} )
		options = DEFAULT_EXPOSURE_OPTIONS.merge( options )

		self.log.debug "Setting up exposure %p %p" % [ name, options ]
		self.exposures[ name ] = options
	end


	### Create a new Presenter for the given +subject+.
	def initialize( subject )
		@subject = subject
	end


	######
	public
	######

	##
	# The subject of the presenter, the object that is delegated to when
	# building the representation.
	attr_reader :subject


	### Return a new instance of whatever object type will be used to represent the
	### subject.
	def empty_representation
		return {}
	end


	### Apply the exposures to the subject and return the result.
	def apply
		result = self.empty_representation

		self.class.exposures.each do |name, opts|
			# :TODO: #public_send instead?
			value = self.subject.send( name )
			result[ name.to_sym ] = value
		end

		return result
	end

end # class Presentability::Presenter