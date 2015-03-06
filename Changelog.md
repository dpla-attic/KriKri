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
