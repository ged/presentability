# Presentability - Getting Started

To set up your own presentation layer, there are three steps:

- Set up a Module as a presenter collection.
- Declare one or more _presenters_ within the collection.
- Use the collection to present entities from a service or other limited interface.

For the purposes of this document, we'll pretend we're responsible for creating a JSON web service for Acme Widgets, Inc. We've declared all of our company's code inside the `Acme` namespace. We're using a generic Sinatra-like web framework that lets you declare endpoints like so:

```ruby
get '/status_check' do |parameters|
    return { status: 'success' }.to_json
end
```


## Create a Presenter Collection

A _presenter collection_ is just a Module somewhere within your namespace that one can use to access the declared presenters. You designate it as a presenter collection simply by `extend`ing `Presentability`.

We'll declare ours under `Acme` and call it `Presenters`:

```ruby
require 'presentability'

require 'acme'

module Acme::Presenters
    extend Presentability

    # Presenters will be declared here

end # module Acme::Presenters
```

Since we haven't declared any presenters, the collection isn't really all that useful yet, so let's declare some.


## Declare Presenters

A _presenter_ is an object that is responsible for constructing a _representation_ of another object. There are a number of reasons to use a presenter:

- Security: avoid exposing sensitive data from your domain objects to the public, e.g., passwords, internal prices, numeric IDs, etc.
- Transform: normalize and flatten complex objects to some standard form, e.g., convert `Time` object timestamps to RFC 2822 form.
- Consistency: change your model layer independently of your service's entities, e.g., adding a new column to a model doesn't automatically expose it in the service layer.

The _representation_ is just a simple object that serves as an intermediate form for the transformed object until it is ultimately encoded. The default _representation_ is an empty `Hash`, but you can customize it to suit your needs.

To declare a presenter, we'll call the `presenter_for` method on the presenter collection module, and then call `expose` or `expose_collection` for each attribute that should be exposed.

The first argument to `presenter_for` is the type of object the presenter is for, which can be specified in a couple of different ways. The easiest is to just pass in the class itself. The domain class the Acme service is built around is the Widget, so let's declare a presenter for it:

```ruby
require 'acme/widget'

module Acme::Presenters
    extend Presentability

    presenter_for Acme::Widget do
        expose :name
    end

end # module Acme::Presenters
```

To present an object, call `.present` on the collection module with the object to be presented, and it will return a representation that is a `Hash` with a single `:name` key-value pair:

```ruby
widget = Acme::Widget.where( name: 'The Red One' )
Acme::Presenters.present( widget )
# => { name: "The Red One" }
```

If we want to add a `sku` field to all widgets served by our service, we just add another exposure:

```ruby
expose :sku
```

```ruby
widget = Acme::Widget.where( name: 'The Red One' )
Acme::Presenters.present( widget )
# => { name: "The Red One", sku: 'DGG-17044-0822' }
```

### Overriding Exposures

Sometime you want to alter the value that appears for a particular field. Say, for example, that the SKU that we exposed in our Widget presenter has an internal-only suffix in the form: `-xxxx` that we'd like to avoid exposing in a public-facing service. We can accomplish this by adding a block to it that alters the field from the model. Inside this block, the original object can be accessed via the `subject` method, so we can call the original `#sku` method and truncate it:

```ruby
expose :sku do
    original = self.subject.sku
    return original.sub(/-\d{4}/, '')
end
```

Now the last part of the SKU will be removed in the representation:

```ruby
widget = Acme::Widget.where( name: 'The Red One' )
Acme::Presenters.present( widget )
# => { name: "The Red One", sku: 'DGG-17044' }
```

### Exposure Options

You can also pass zero or more options as a keyword Hash when presenting:

```ruby
Acme::Presenters.present( widget, internal: true )
```

There are a few ways options can be used out of the box:

#### Exposure Aliases

Sometimes you want the field in the representation to have a different name than the method on the model object:

```ruby
presenter_for Acme::Company do
    expose :id
    expose :legal_entity, as: :name
    expose :icon_url, as: :icon
end
```

In the representation, the `#legal_entity` method will be called on the `Company` being presented and the return value associated with the `:name` key, and the same for `#icon_url` and `:icon`:

```ruby
{ id: 4, name: "John's Small Grapes", icon: "grapes-100.png" }
```

#### Conditional Exposure

You can make an exposure conditional on an option being passed or not:

```ruby
# Don't include the price if presented with `public: true` option is set
expose :price, unless: :public

# Only include the settings if presented with `detailed: true` option is set
expose :settings, if: :detailed
```

#### Collection Exposure

A common use-case for conditional presentations is when you want an entity in a collection to be a less-detailed version. E.g.,

```ruby
presenter_for Acme::User do
    expose :id
    expose :username
    expose :email

    expose :settings, unless: :in_collection
end
```

You can pass `in_collection: true` when you're presenting, but you can also use the `present_collection` convenience method which sets it for you:

```ruby
users = Acme::User.where( :activated ).limit( 20 )
Acme::Presenters.present_collection( users )
# => [{ id: 1, username: 'fran', email: 'fran@example.com'}, ...]
```

#### Custom Options

You also have access to the presenter options (via the `#options` method) in a overridden exposure block. With this you can build your own presentation logic:

```ruby
presenter_for Acme::Widget do
    expose :name
    expose :sku

    expose :scancode do
        self.subject.make_scancode( self.options[:scantype] )
    end
end

# In your service:
widget = Acme::Widget[5]
Acme::Presenters.present( widget, scantype: :qr )
# { name: "Duck Quackers", sku: 'HBG-121-0424', scancode: '<qrcode data>'}
```


## Declare Serializers

Oftentimes your model objects include values which are themselves not inherently serializable to your representation format. To help with this, you can also declare a "serializer" for one or more classes in your collection using the `.serializer_for` method:

```ruby
require 'time' # for Time#rfc2822

module Acme::Presenters
    extend Presentability

    serializer_for :IPAddr, :to_s
    serializer_for Time, :rfc2822
    serializer_for Set, :to_a

end # module Acme::Presenters
```

Now when one of your models includes any of the given types, the corresponding method will be called on it and the result used as the value instead.

## Use the Roda Plugin

If you're using the excellent [Roda](https://roda.jeremyevans.net/) web framework, `Presentability` includes a plugin for using it in your Roda application. To enable it, in your app just `require` your collection and enable the plugin. That will enable you to use `#present` and `#present_collection` in your routes:

```ruby
require 'roda'
require 'acme/presenters'

class Acme::WebService < Roda

    plugin :presenters, collection: Acme::Presenters
    plugin :json

    route do |r|
        r.on "users" do
            r.is do
                # GET /users
                r.get do
                    users = Acme::User.where( :activated )
                    present_collection( users.all )
                end
            end
        end
    end
end # class Acme::WebService
```

