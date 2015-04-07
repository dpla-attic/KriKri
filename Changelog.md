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
