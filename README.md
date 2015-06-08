Kri-Kri
=======

[![Build Status](https://travis-ci.org/dpla/KriKri.svg?branch=develop)](https://travis-ci.org/dpla/KriKri) [![Code Climate](https://codeclimate.com/github/dpla/KriKri/badges/gpa.svg)](https://codeclimate.com/github/dpla/KriKri) [![Test Coverage](https://codeclimate.com/github/dpla/KriKri/badges/coverage.svg)](https://codeclimate.com/github/dpla/KriKri)

A Rails engine for metadata aggregation, enhancement, and quality control.
[Digital Public Library of America](http://dp.la/) uses Kri-Kri as part of
[Heiðrún](https://github.com/dpla/heidrun), its metadata ingestion system.

[More information](https://digitalpubliclibraryofamerica.atlassian.net/wiki/display/TECH/Heidrun) about Heidrun and Kri-kri can be found on [DPLA's Technology Team site](https://digitalpubliclibraryofamerica.atlassian.net/wiki/display/TECH).

Installation
-------------

1. Add the `krikri` gem to your Gemfile.

2. Run `bundle exec rails g krikri:install`

   This will modify your Gemfile, so you should check it for redundancies.

3. The install task will have added `mount Krikri::Engine => '/krikri'` to
   your routes.rb.  You may customize the path.

4. Run `bundle exec rake db:migrate`

5. You may run `bundle exec rake routes` to inspect the new routes that
   will have been added, and `bundle exec rails s` to check that the new
   resources are served.

6. See [the Resque documentation](https://github.com/resque/resque/tree/1-x-stable)
   on how to run queue workers.  There will be a console for the Resque job
   queue available as '/resque' under the Krikri base path in your web
   application.


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

Customization
-------------

Krikri uses Blacklight.  Blacklight's installation process includes the
creation of some routes that Krikri does not use.  Blacklight also roots to one
of these un-used routes.  We suggested removing both the un-used routes and the
root route by deleting the following line from `config/routes.rb`:

    blacklight_for :catalog
    root :to => "catalog#index"

You can then choose a different route to root to, for example:

  root :to => "krikri_records#index"

Note that whether or not you delete the un-used Blacklight routes, Blacklight's
controllers, models, and views still exists within your application.  Be careful
not to unintentionally open them by using identical names for your controllers,
models, and views.  For more information, see [Blacklight's website](https://github.com/projectblacklight/blacklight).


Sample Data
-----------

To save a sample record to Solr and Marmotta, from `/krikri/spec/internal`:

    rake krikri:samples:save_record

To save an _invalid_ sample record to Solr and Marmotta:

    rake krikri:samples:save_invalid_record

To delete all sample records:

    rake krikri:samples:delete_record

To save a sample institution and harvest source, from `/krikri/spec/internal`:

    rake krikri:samples:save_institution

To delete the sample institution and harvest source:

    rake krikri:samples:delete_institution


Using Vagrant for development (experimental)
--------------------------------------------

Prerequisites:

* [VirtualBox](https://www.virtualbox.org/) (Version 4.3)
* [Vagrant](http://www.vagrantup.com/) (Version 1.6)
* [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest/) (`vagrant plugin install vagrant-vbguest`)
* [Ansible](http://www.ansible.com/) (Version 1.7 or greater; [installation instructions](http://docs.ansible.com/intro_installation.html))


For installation:

    vagrant up
    vagrant reload  # Because of o/s packages having been upgraded
    vagrant ssh
    cd /vagrant
    bundle exec rake jetty:start
    cd spec/internal
    bundle exec rake krikri:index_sample_data
    bundle exec rails s

Then access the wrapper application at http://localhost:3000/

From then on, to start things up, do:

    vagrant up
    vagrant ssh
    cd /vagrant
    bundle exec rake jetty:start
    cd /vagrant/spec/internal
    bundle exec rails s

You may re-run the provisioning with `vagrant provision`.  This will
clean and re-create the Jetty installation.  (So don't do it if you want to
preserve your Marmotta or Solr.)  A future update will include more
specific configuration and update tasks.

Please see [the notes in our automation project README](https://github.com/dpla/automation/blob/develop/README-ingestion2.md#when-to-use-this-and-other-dpla-project-vms)
regarding the use of this VM.

Using Guard for tests
---------------------

Guard is configured with RSpec; you can run `guard` to enable specs to run as
configured in the `Guardfile`.

Known Issues
------------

Our `krikri:install` generator will install [Blacklight](https://github.com/projectblacklight/blacklight).
Blacklight is known not to  work well with `turbolinks`, so you should
uninstall that if it's installed already:

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

  - Copyright Digital Public Library of America, 2014-2015
  - License: MIT
