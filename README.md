Kri-Kri
=======

A Rails engine for metadata aggregation, enhancement, and quality control.

Installation
-------------

1. Add the `krikri` gem to your Gemfile.

2. Run `bundle exec rails g krikri:install`

   This will modify your Gemfile, so you should check it for redundancies.

3. The install task will have added `mount Krikri::Engine => '/krikri'` to
   your routes.rb.  You may customize the path.

4. Run `bundle exec rake db:migrate`

5. You may run `bundle exec rails routes` to inspect the new routes that
   will have been added, and `bundle exec rails s` to check that the new
   resources are served.


Development
-----------

Check out this repository and run:

    bundle install
    rake jetty:unzip
    rake jetty:config

Run the tests with:

    rake ci

Or you can start the dummy application with:

    rake engine_cart:generate
    bundle update
    rake jetty:start
    cd spec/internal
    rails s

To index a sample record into solr, from `/krikri/spec/internal`:
    rake krikri:index_sample_data

To delete the sample record:
    rake krikri:delete_sample_data

To update/restart dummy application, from the root KriKri directory:
    git pull
    bundle update
    rake engine_cart:clean
    rake engine_cart:generate
    cd spec/internal
    rails s

To update/restart jetty, from the root KriKri directory:
    git pull
    bundle update
    rake jetty:stop
    rake jetty:config
    rake jetty:start

To create a sample institution and harvest source, from `/krikri/spec/internal`:
    rake krikri:create_sample_institution

To delete the sample institution and harvest source:
    rake krikri:delete_sample_institution

Known Issues
------------

Our `krikri:install` generator will install Blacklight.  Blacklight is known not to
work well with `turbolinks`, so you should uninstall that if it's installed already:

http://blog.steveklabnik.com/posts/2013-06-25-removing-turbolinks-from-rails-4

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
