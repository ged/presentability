# -*- ruby -*-

require 'presentability'

require 'roda/roda_plugins' unless defined?( Roda::RodaPlugins )


module Roda::RodaPlugins::Presenters

	# Default options
	OPTS = {}.freeze


	### Add presenter variables to the given +app+.
	def self::configure( app, opts=OPTS, &block )
		collection = opts[:collection] || Module.new
		app.singleton_class.attr_accessor :presenter_collection
		app.presenter_collection = collection
	end


	module ClassMethods

		### Inheritance hook -- give +subclass+es their own presenters ivar.
		def inherited( subclass )
			super
			subclass.presenter_collection = self.presenter_collection.clone
		end


	end # module ClassMethods


	module InstanceMethods

		### Find the presenter for the given +object+ and apply it with the given
		### +options+. Raises an exception if no presenter can be found.
		def present( object, **options )
			mod = self.class.presenter_collection
			return mod.present( object, **options )
		end


		### Find the presenter for the given +object+ and apply it with the given
		### +options+. Raises an exception if no presenter can be found.
		def present_collection( object, **options )
			mod = self.class.presenter_collection
			return mod.present_collection( object, **options )
		end

	end


	Roda::RodaPlugins.register_plugin( :presenters, self )

end # module Roda::RodaPlugins::Presenters

