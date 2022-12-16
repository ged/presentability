
A presenter (facade) base class.


### Declaring Presenters

When you declare a presenter in a Presentability collection, the result is a
subclass of Presentability::Presenter. The main way of defining a Presenter's
functionality is via the ::expose method, which marks an attribute of the underlying
entity object (the "subject") for exposure.

    class MyPresenter < Presentability::Presenter
      expose :name
    end
    
    # Assuming `entity_object' has a "name" attribute...
    presenter = MyPresenter.new( entity_object )
    presenter.apply
    # => { :name => "entity name" }


### Presenter Collections

Setting up classes manually like this is one option, but Presentability also lets you
set them up as a collection, which is what further examples will assume for brevity:

    module MyPresenters
      extend Presentability
    
      presenter_for( EntityObject ) do
        expose :name
      end
    
    end


### Complex Exposures

Sometimes you want to do more than just use the presented entity's values as-is. There are a number of ways to do this.

The first of these is to provide a block when exposing an attribute. The subject of the presenter is available to the block via the `subject` method:

    require 'time'
  
    presenter_for( LogEvent ) do
      # Turn Time objects into RFC2822-formatted time strings
      expose :timestamp do
        self.subject.timestamp.rfc2822
      end
  
    end

You can also declare the exposure using a regular method with the same name:

    require 'time'
  
    presenter_for( LogEvent ) do
      # Turn Time objects into RFC2822-formatted time strings
      expose :timestamp

      def timestamp
        return self.subject.timestamp.rfc2822
      end
  
    end

This can be used to add presence checks:

    require 'time'
  
    presenter_for( LogEvent ) do
      # Require that presented entities have an `id` attribute
      expose :id do
        id = self.subject.id or raise "no `id' for %p" % [ self.subject ]
        raise "`id' for %p is blank!" % [ self.subject ] if id.blank?

        return id
      end
    end

or conditional exposures:

    presenter_for( Acme::Product ) do
    
      # Truncate the long description if presented as part of a collection
      expose :detailed_description do
        desc = self.subject.detailed_description
        if self.options[:in_collection]
          return desc[0..15] + '...'
        else
          return desc
        end
      end
    
    end
