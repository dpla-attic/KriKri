0.15.0 (10 Sep 2016)
---

* Add DSL method for accessing field names
* Handle `JSONParser#get_child_node` for nested arrays
* Allow Travis failures for unsupported Rubies

0.14.0 (22 Aug 2016)
---

* Match/reject mapping DSL nodes based on presence of child node
* Fix RSpec warning on `raise_error`
* Use providedLabel in TimeSpan for MAP 3.1
* Avoid calling `Registry#get` repeatedly in mapping
* Restore `ValueArray` in scoped DSL variables
* Upgrade EDTF to 3.0
* Drop support for ruby 2.3.0
* Update solr schema
  * Update fields to reflect most recent version of DPLA::MAP
  * Remove un-necesary fields
* Add QA features
  * Gallery view for search results
  * Deliminate feilds with semicolon in search results
  * Add more field value reports
  * Add facets for both pref and providedLabel
* Add Scott as author

0.13.2 (13 July 2016)
---

* Change MAP 3.1 Crosswalk to use `providedLabel` for Place display labels

0.13.1 (11 July 2016)
---

* Add enrichment to generate a label from an existing TimeSpan

0.13.0 (6 July 2016)
---

* Mapping DSL improvements
  * Add #at and #compact methods
  * Support binding arbitrary named variables for later recall;
    (#bind, #and(from:))
* Change MAP 3.1 mapping to allow use of providedLabels from TimeSpan
* Raise default bulk index batch size (now: 1000)
* Migrate shared engine examples to new `krikri-spec` gem.
  * This supports including examples in implementing apps; better testing
    of upstream Harvesters, &tc...
* Upgrade RSpec to `~> 3.3`
* Upgrade Nokogiri (security fix)
* Remove development dependency on Guard


0.12.4 (11 April 2016)
---

* Fix bug in handling of EDTF intervals in the extended date parser
* Add an enrichment to splits a resource into multiple resources when
  multiple providedLabels are present.
* Make language code matching case insensitive. E.g. "Eng" now matches
  the code `eng`.
* Allow multiple descriptions in the MAP 3.1 crosswalk.

0.12.3 (17 March 2016)
---

* Only inline exceptions stemming from Faraday

0.12.1 (17 March 2016)
---

* Raise error for empty original record, minting ID ([#8316](https://issues.dp.la/issues/8316))
* Krikri::AsyncUriGetter: Add support for "inline exceptions"
* Let CodeClimate through webmock always
* Remove Solr docs more carefully in test suite

0.12.0 (7 March 2016)
---

Changes from 0.12.0-rc.1, plus:

* Force bundler version
* Refactor SoftwareAgent's use of entity_behavior
* Use default entity behavior for agent in Activity
* Fix definition of Krikri::Harvester.entity_behavior
* Add Ruby 2.3.0 to build list

0.12.0-rc.1 (24 February 2016)
---
* Update SPARQL query, Activity for invalidated records
* Allow use of RSpec 3.4.x
* Disable Spring (development VM)
* Set global rbenv version (development VM)
* Introduce OriginalRecord load failure Error class
* Call `next` when logging errors in `#record`
* Bump read timeout for Marmotta SPARQL client

0.11.2 (18 January 2016)
---
* Allow OAI Harvester to use arbitrary metadata properties for an ID source.

0.11.1 (18 January 2016)
---
* Limit cache size for RDF::URIs; adds a configuration option
`uri_cache_size` to control the limit. Users may consider a large cache
size on the webserver, while using a smaller size on worker boxes.

0.11.0 (13 January 2016)
---
* Adds a utility for threaded HTTP requests for use by Harvesters.
* Implements soft-delete via PROV Invalidation for LDP-RSs.
* `DPLA::MAP::Aggregation#dpla_id` introduced to return the unique portion of
an Aggregation`s URI.
* Fixes timespan (temporal/date) consistency in crosswalk between MAP 4.0 and
3.1.

0.10.1 (22 November 2015)
---
* Patch error in DPLA MAP v3.1 mapping for coordinates

0.10.0 (24 November 2015)
---
* Introduce a Primo harvester

0.9.0 (23 November 2015)
---
* Introduce a MARC XML harvester
* Expose local_name through the Parser interface

0.8.9 (11 November 2015)
---
* Allow OAI harvester to recover on errors when iterating sets, passing over
and logging any errored sets.

0.8.8 (04 November 2015)
---
* Forces encoding to UTF-8 in LDP Turtle responses. This improves response
handling when encoding is ambiguous to `Net::HTTP`.

0.8.7 (04 November 2015)
---
* Add error handling to mapping. Collects errors encountered while
mapping an `OriginalRecord` in a `Mapping::Error` class. Errors are then
logged as a group with information about which declarations were processing
when the error was encountered.
* Upgrade `RDF::Turtle` to 1.1.8; revert longlines behavior and use the
faster Turtle parser.
* Pin RDF.rb to version 1.1.x, avoiding an upgrade to 1.99.0.

0.8.6 (04 September 2015)
---
* Fix a bug in the RDF::Turtle parser which effected loading graphs with
long, multi-line literals.

0.8.5 (01 September 2015)
---
* Add enrichment to remove Blank Node `WebResource`s
* Improve `SearchIndex` initializer to merge passed options with
defaults, instead of using one or the other.

0.8.4 (28 August 2015)
---
* Update DPLA MAP 3.1 Crosswalk

0.8.3 (25 August 2015)
---
* Add application wide tagged logging
* Handle errors in indexer
* Indexer: Fix prefLabel issue in map_crosswalk
* Make Activity respond to #to_term
* Add `Activity#to_s` for easier activity display
* Mapper: allow static values on `:each`
* Mapper: handle literal values from `record` in :each

0.8.2 (18 August 2015)
---
* Upgrades DPLA::MAP to remove LinkedVocab dependency
  * Fixes a bug with blank node identity in language and genre 

0.8.1 (14 August 2015)
---
* Fix FieldValueReport error where nil can't be coerced into Fixnum 

0.8.0 (12 August 2015)
---
* Adds field value report 
  * Add downloadable CSV reports for field values.
  * Add new ActiveModelBase class, which is extended by FieldValueReport
  and Provider.
* Updates DPLA::MAP dependency, fixing an issue with
`SourceResource#language` accessors.
* Fixes two bugs on string enrichments:
  * Ending punctuation enrichment left some ending periods that were
  intended to be removed.
  * Remove empty fields enrichment treated fields beginning with
  whitespace followed by a newline as "whitespace-only" regardless of
  other content.

0.7.6 (8 August 2015)
---
* Pin rails_config to version 0.4.0

0.7.5 (31 July 2015)
---
* Add prefLabels to languages
* Display only the `@graph` in JSON-LD displays

0.7.4 (23 July 2015)
---
* Check for existence of provider_name when building navigation

0.7.3 (22 July 2015)
---
* Adds `#reject_attribute` as a DSL method
  * Extends both `#select_attribute` and `#reject_attribute` with block handling
* Builds Providers from the search index for a SPARQL-free frontend
* Upgrades to Ruby OAI 0.4.0;
  * uses the new `#_source` method to access XML for OriginalRecord bodies

0.7.2 (15 July 2015)
---
* Adds enrichment to copy `providedLabel` to `prefLabel`
* Commits to SOLR when running bulk adds to a QA index
* Introduces HTTP request logging (via Faraday) for OAI harvests

0.7.1 (01 July 2015)
---
* Reduce post-save HEAD/GET requests making `#save` calls cheaper.
  * This exposes LDP PUT requests to HTTP 409 (conflict) and HTTP 412
    (precondition failed) in some save-edit-save scenarios. You can fix 
    these cases by using `RdfSource#save_and_reload` for RDF records and
    `OriginalRecord#http_head(true)` after the initial save for Original 
    Records.
* Graceful error handling empty/non-existent root nodes in XmlParser
  * Records with no root node are passed over and logged.

0.7.0 (24 June 2015)
---
* Extract Enrichment/FieldEnrichment to [Audumbla](https://github.com/dpla/audumbla) gem
* Update documentation for mapping related modules
* Pin bootstrap-sass to 3.3.4.1 and rspec-rails to ~> 3.2.0

0.6.0 (8 June, 2015)
---
* Modify solrconfig.xml to use correct field names
* Change facet configuration and routing
* Remove scroll from side-by-side records, QA interface
* Change index fields for records in Solr
* Add VM usage note to README
* Add Krikri::MARCXMLParser
* Add "or" expressions, Krikri::Parser::Value
* Add ISO enrichment
* Fix: Do not obliterate defaults, QASearchIndex constructor

0.5.7 (16 April 2015)
---
* Update MAPv3.1 mapping with edm:object fix

0.5.6 (16 April 2015)
---
* Add Enrichment instance caching to Enricher
* Create enrichment to split a resource by its providedLabel
* Format Aggregations to MAP 3.1 for indexing

0.5.5 (12 April 2015)
---
* Add a variety of enrichments
  * Bnode Deduplication enrichment
  * "DCMI Enforcer" enrichment
  * DCMIType mapping enrichment
  * Split coordinates (when given in a single field as lat, long or long, lat)
  * `ConvertToSentenceCase` enrichment
  * Enrichment to copy non-DCMI type values
  * Enrichment to truncate string at 1000 characters
* `#last_value` method to get the last parsed value in the Mapping DSL

0.5.4 (9 April 2015)
---
* QA interface bug fixes
    * Fix RecordsController to use correct Solr field names
    * Refactor Krikri::Harvesters::CouchdbHarvester
* Update dataProvider field in validation report
    * Exclude design docs
    * Refactor specs for CouchdbHarvester
    * Test that `#records` iterates over pages
    * Have CouchdbHarvester make batch requests

0.5.3 (7 April 2015)
---

* Rewrite validation reports model/controller - addresses pagination issues

0.5.2 (6 April 2015)
---

* Fixup validation report views
* Krikri::Provider-related performance improvements:
    * Remove record counts from provider index view
    * Cache `all_providers` for navigation bar.
    * Krikri::Provider#reload query should use a DISTINCT clause

0.5.1 (4 April 2015)
---

* Improve `SoftwareAgent`/`Job` activity URI handling

0.5.0 (3 April 2015)
---

NOTE: Run `rake db:migrate` when upgrading to this release. If you have
production data in your Solr index, you will need to reindex your items.

* Support multivalued node fields in solr index
* Fix Solr document ID builder regression which modifies item container
* Fix validation report's use of IDs
* Revamp provider controller for cleaner REST interactions
* Adds QA Reports MVC
* Add SPARQL queries for QA
* Make `Provider` an ActiveTriples::Resource
* QA by provider
* Check existence of Blacklight settings file
* Improve indexing of property values /w many nodes
* Fixes rake sample record
* Add and refactor search indexing, and add associated behaviors
* Add a test that covers Enricher#do_basic_enrichment

0.4.0 (23 March 2015)
---

* Add `Enricher` to queue and run enrichment chains as Activities
* Use local names instead of full URIs as record IDs in routes
* Add a small suite of enrichments to strip punctuation from fields
* Add a basic genre filter enrichment
* Better format support for date parsing/enrichment

0.3.3 (10 March 2015)
---

NOTE: Run `rake db:migrate` when upgrading to this release

* Change Activity.opts to :text, allowing long option strings

0.3.2 (10 March 2015)
---

NOTE: Run `rake db:migrate` when upgrading to this release

* More complete laziness on multi-set OAI harvests
  * Fixes resumption token expiration
* Add `#map` to mapping DSL Parser::ValueArray methods

0.3.1 (6 March 2015)
---

* Feature-less release fixes a problem with the v0.3.0 gem

0.3.0 (6 March 2015) (revoked)
---

* Build Set support into `OAIHarvester`
  * Add `#sets` to manage calls to OAI's ListSet verb
  * Add options to harvest multiple sets and blacklist sets from a harvest
* Create `HarvestBehavior` concept to specify record handling actions
  * Add behavior to skip deleted records in OAI harvests (default)
* Add header mixin to OAI QDC and MODS parsers
* Rework `#header` parser method to be more flexible in where it is called
* Make OA index settings configurable & compatible with Blacklight config
* Update marmotta-jetty to 3.3.0-solr-4.10.3

0.2.1 (24 Feburary 2015)
---

* Set fragment URI for first sourceResource on ore:Aggregations

0.2.0 (23 February 2015)
---

* Simplify `#enqueue` interface and dependencies
* Add random record view for QA interface
* Add `#header` node as mixin for OAI Parsers
* Make Krikri::Mapper#map's exception handling more robust
* Test refactor for SoftwareAgent [minor]
* Add ability select multiple fields from ValueArray
* Streamline and improve Rake tasks

0.1.3 (6 February 2015)
---

* Add LDP request, Harvester, Mapper, and Activity error logging/handling,
and retry failed requests when necessary.
* Add original and mapped/enriched record comparison view.
* Add date normalization.
* Simplify CouchdbHarvester#get_record
* Jettywrapper configuration changes and improvements.
* Skip unavailiable fields in FieldEnrichment.
* Avoid the rdf-marmotta Repository for SPARQL.

0.1.0 (30 January 2015)
---

* Initial public release
