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
    rake jetty:config
    rake marmotta:fetch
    rake marmotta:install

Run the tests with:

    rake ci

Or you can start the dummy application with:

    rake engine_cart:generate
    bundle update
    rake jetty:start
    cd spec/internal
    rails s

To index a sample record into solr:
    rake krikri:index_sample_data

To delete the sample record:
    rake krikri:delete_sample_data

Contribution Guidelines
-----------------------
Please observe the following guidelines:

  - Write tests for your contributions.
  - Document methods you add using YARD annotations.
  - Follow the included style guidelines (i.e. run `rubocop` before committing).
  - Use well formed commit messages.

Copyright & License
--------------------

Copyright Digital Public Library of America, 2014
