
Facade-based presenter toolkit with minimal assumptions.

## Basic Usage

Basic usage of Presentability requires two steps: declaring presenters and
then using them.

### Declaring Presenters

Presenters are just regular Ruby classes with some convenience methods for
declaring exposures, but in a lot of cases you'll want to declare them all in
one place. Presentability offers a mixin that implements a simple DSL for
declaring presenters and their associations to entity classes, intended to be
used in a container module:

    require 'presentability'

    module Acme::Presenters
      extend Presentability
  
      presenter_for( Acme::Widget ) do
      	expose :sku
      	expose :name
      	expose :unit_price
      end
  
    end

The block of `presenter_for` is evaluated in the context of a new Presenter
class, so refer to that documentation for what's possible there.

Sometimes you can't (or don't want to) have to load the entity class to
declare a presenter for it, so you can also declare it using the class's name:

    presenter_for( 'Acme::Widget' ) do
      expose :sku
      expose :name
      expose :unit_price
    end


### Using Presenters

You use presenters by instantiating them with the object they are a facade for
(the "subject"), and then applying it:

    acme_widget = Acme::Widget.new(
      sku: "FF-2237H455",
      name: "Throbbing Frobnulator",
      unit_price: 299,
      inventory_count: 301,
      wholesale_cost: 39
    )
    presentation = Acme::Presenters.present( acme_widget )
    # => { :sku => "FF-2237H455", :name => "Throbbing Frobnulator", :unit_price => 299 }

If you want to present a collection of objects as a collection, you can apply presenters to the collection instead:

    widgets_in_stock = Acme::Widget.where { inventory_count > 0 }
    collection_presentation = Acme::Presenters.present_collection( widgets_in_stock )
    # => [ {:sku => "FF-2237H455", [...]}, {:sku => "FF-2237H460", [...]}, [...] ]

The collection can be anything that is `Enumerable`.


### Presentation Options

Sometimes you want a bit more flexibility in what you present, allowing a single uniform presenter to be used in multiple use cases. To facilitate this, you can pass an options keyword hash to `#present`:

    presenter_for( 'Acme::Widget' ) do
      expose :sku
      expose :name
      expose :unit_price
      
      # Only expose the wholesale cost if presented via an internal API
      expose :wholesale_cost, if: :internal_api
    end

    acme_widget = Acme::Widget.new(
      sku: "FF-2237H455",
      name: "Throbbing Frobnulator",
      unit_price: 299,
      inventory_count: 301,
      wholesale_cost: 39
    )
    
    # External API remains unchanged:
    presentation = Acme::Presenters.present( acme_widget )
    # => { :sku => "FF-2237H455", :name => "Throbbing Frobnulator", :unit_price => 299 }

    # But when run from an internal service:
    internal_presentation = Acme::Presenters.present( acme_widget, internal_api: true )
    # => { :sku => "FF-2237H455", :name => "Throbbing Frobnulator", :unit_price => 299,
    #      :wholesale_cost => 39 }

There are some options that are set for you:

<dl>
<td><code>:in_collection</code></td>
<dd>Set if the current object is being presented as part of a collection.</dd>
</dl>



