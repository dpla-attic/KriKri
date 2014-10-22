Kri-Kri
=======

A Rails engine for metadata aggregation, enhancement, and quality control.

Installation
-------------

Add `krikri` to your Gemfile, and mount it by editing your application's `config/routes.rb`
to include:

    mount Krikri::Engine, at: "/"

Development
-----------

Check out this repository and run:

    bundle install
	rake jetty:unzip
    # rake app:marmotta:fetch
    # rake app:marmotta:install

Run the tests with:

    rake ci

Or you can start the dummy application with:

    rake jetty:start
	cd spec/internal
	rails s

Copyright & License
--------------------
	
Copyright Digital Public Library of America, 2014

