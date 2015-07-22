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
