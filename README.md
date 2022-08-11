# Presentability

home
: https://hg.sr.ht/~ged/Presentability

code
: https://hg.sr.ht/~ged/Presentability

github
: https://github.com/ged/presentability

docs
: https://deveiate.org/code/presentability


## Description

Facade-based presenters with minimal assumptions. This library contains
utilities for setting up presenters for data classes for things like web
services, logging output, etc.

It is intended to be dead-simple by default, returning a Hash containing
only the attributes you have intentionally exposed from the subject.

The most basic usage looks something like this:

    require 'presentatbility'

    # lib/acme/presenters.rb
    module Acme::Presenters
      extend Presentability
      
      presenter_for Acme::Widget do
        expose :sku
        expose :name
        expose :unit_price
      end
    end

    # lib/acme/service.rb
    class Acme::Service < Some::Webservice::Framework
    
      get '/api/widgets/<sku>' do |sku|
        widget = Acme::Widget.lookup( sku )
        content_type 'application/json'
        representation = Acme::Presenters.present( widget )
        return representation.to_json
      end
    
    end

Note that Presentability doesn't do any encoding for you, or infer anything, or
require that you alter your data classes. It's just a collection of Facades for
your data objects that return a limited representation of their subjects.

More details can be found in the docs for the Presentability module, and in
Presentability::Presenter.


## Prerequisites

* Ruby


## Installation

    $ gem install presentability


## Contributing

You can check out the current development source with Mercurial via its
[project page](http://bitbucket.org/ged/presentability). Or if you prefer Git, via
[its Github mirror](https://github.com/ged/presentability).

After checking out the source and changing into the resulting directory, run:

    $ gem install -Ng
    $ rake setup

This will install dependencies, and do any other necessary setup for development.


## Authors

- Michael Granger <ged@faeriemud.org>


## License

Copyright (c) 2022, Michael Granger
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the author/s, nor the names of the project's
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


