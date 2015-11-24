require 'active_support/core_ext/string/strip'

FactoryGirl.define do

  factory :krikri_original_record, class: Krikri::OriginalRecord do
    content ''
    initialize_with { new('123') }
  end

  factory :oai_dc_record, parent: :krikri_original_record do
    content <<-EOS.strip_heredoc
<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="static/oai2.xsl"?><OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"><responseDate>2014v-10-27T22:19:17Z</responseDate><request verb="GetRecord" identifier="oai:oaipmh.huygens.knaw.nl:arthurianfiction:MAN0000000010" metadataPrefix="oai_dc">http://oaipmh.huygens.knaw.nl/</request><GetRecord><record><header><identifier>oai:oaipmh.huygens.knaw.nl:arthurianfiction:MAN0000000010</identifier><datestamp>2012-07-13T14:27:31Z</datestamp><setSpec>arthurianfiction:manuscript</setSpec><setSpec>arthurianfiction</setSpec></header><metadata><oai_dc:dc xmlns:cmdi="http://www.clarin.eu/cmd/" xmlns:database="http://www.oclc.org/pears/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://www.clarin.eu/cmd/ http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1345561703673/xsd">
   <dc:title>Aberystwyth, National Library of Wales, 446-E</dc:title>
   <dc:creator>Bart Besamusca</dc:creator>
   <dc:creator>Tove Jansson</dc:creator>
   <dc:creator>Moomin Papa</dc:creator>
   <dc:identifier>https://service.arthurianfiction.org/manuscript/MAN0000000010</dc:identifier>
   <dc:date>2012-07-13T14:27:31Z</dc:date>
   <dc:contributor>Bart Besamusca</dc:contributor>
   <dc:type>model</dc:type>
   <dc:language>eng</dc:language>
</oai_dc:dc></metadata>
<about>
  <oaiProvenance:provenance xmlns:oaiProvenance="http://www.openarchives.org/OAI/2.0/provenance" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/provenance http://www.openarchives.org/OAI/2.0/provenance.xsd">
    <oaiProvenance:originDescription harvestDate="2015-01-07" altered="true">
    <oaiProvenance:baseURL>http://cdm16694.contentdm.oclc.org/oai/oai.php</oaiProvenance:baseURL>
    <oaiProvenance:identifier>oai:cdm16694.contentdm.oclc.org:R6A001/1</oaiProvenance:identifier>
    <oaiProvenance:datestamp>2015-01-07</oaiProvenance:datestamp>
    <oaiProvenance:metadataNamespace>http://www.openarchives.org/OAI/2.0/</oaiProvenance:metadataNamespace>
  </oaiProvenance:originDescription>
</oaiProvenance:provenance>
</about></record></GetRecord></OAI-PMH>
EOS
  end

  factory :oai_deleted_record, parent: :krikri_original_record do
    content <<-EOS.strip_heredoc
<?xml version="1.0" encoding="UTF-8" ?>
<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
         http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
  <responseDate>2015-03-02T15:56:51Z</responseDate>
  <request verb="ListRecords" metadataPrefix="oai_dc">https://digital.library.in.gov/OAI/Server</request>
    <ListRecords>
      <record>
        <header status="deleted">
          <identifier>oai:digital.library.in.gov:ACPL_coll14-1</identifier>
          <datestamp>1969-12-31T19:00:00Z</datestamp>
        </header>
      </record>
    </ListRecords>
  </request>
</OAI-PMH>
EOS
  end

  factory :cdm_qdc_record, parent: :krikri_original_record do
    content <<-EOS.strip_heredoc
<?xml version="1.0" encoding="UTF-8"?><OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"><responseDate>2015-01-26T19:32:57Z</responseDate><request verb="ListRecords" resumptionToken="p15799coll82:40000:oclc-cdm-allsets:0000-00-00:9999-99-99:oai_qdc" metadataPrefix="oai_qdc">http://digitallibrary.usc.edu/oai/oai.php</request><ListRecords><record><header><identifier>oai:digitallibrary.usc.edu:p15799coll117/0</identifier><datestamp>2012-11-07</datestamp><setSpec>p15799coll117</setSpec></header>
<metadata>
<oai_qdc:qualifieddc xmlns:oai_qdc="http://worldcat.org/xmlschemas/qdc-1.0/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://worldcat.org/xmlschemas/qdc-1.0/ http://worldcat.org/xmlschemas/qdc/1.0/qdc-1.0.xsd http://purl.org/net/oclcterms http://worldcat.org/xmlschemas/oclcterms/1.4/oclcterms-1.4.xsd">
<dc:title>Letter, Cornelia A. Kelley to Andrew Viterbi, February 25, 2000</dc:title>
<dc:publisher>University of Southern California. Libraries</dc:publisher>
<dcterms:created>2000/2000</dcterms:created>
<dcterms:created>2000</dcterms:created>
<dc:type>item</dc:type>
<dcterms:isPartOf>Boston Latin School</dcterms:isPartOf>
<dc:source>University of Southern California</dc:source>
<dc:source>Box 1, Folder 2</dc:source>
<dc:identifier>vit-m15</dc:identifier>
<dcterms:isPartOf>vit-m1</dcterms:isPartOf>
<dcterms:isPartOf>Andrew J. and Erna Viterbi Family Archives</dcterms:isPartOf>
<dcterms:isPartOf>Academic Affiliations</dcterms:isPartOf>
<dc:rights>There are materials within the archives that are marked confidential or proprietary, or that contain information that is obviously confidential. Examples of the latter include letters of references and recommendations for employment, promotions, and awards; nominations for awards and honors; resumes of colleagues of Dr. Viterbi; and grade reports of students in Dr. Viterbi&#x27;s classes at the University of California, Los Angeles, and the University of California, San Diego.; These restricted items were not scanned and, therefore, are not included in the USC Digital Archive.; Researchers wishing to see any of the restricted materials should consult with the USC Libraries Special Collections staff.</dc:rights>
<dcterms:accessRights>There are materials within the archives that are marked confidential or proprietary, or that contain information that is obviously confidential. Examples of the latter include letters of references and recommendations for employment, promotions, and awards; nominations for awards and honors; resumes of colleagues of Dr. Viterbi; and grade reports of students in Dr. Viterbi&#x27;s classes at the University of California, Los Angeles, and the University of California, San Diego.; These restricted items were not scanned and, therefore, are not included in the USC Digital Archive.; Researchers wishing to see any of the restricted materials should consult with the USC Libraries Special Collections staff.</dcterms:accessRights>
<dcterms:rightsHolder>USC Libraries Special Collections</dcterms:rightsHolder>
<dc:rights>Doheny Memorial Library 206, 3550 Trousdale Parkway, Los Angeles, California,90089-0189, 213-740-4035, specol@usc.edu</dc:rights>
<dc:identifier>VIT-000014</dc:identifier>
<dc:identifier>http://digitallibrary.usc.edu/cdm/ref/collection/p15799coll117/id/0</dc:identifier></oai_qdc:qualifieddc>
</metadata>
</record>
</ListRecords>
</OAI-PMH>
EOS
  end

  factory :json_record, parent: :krikri_original_record do
    initialize_with { new('456') }
    rec = {
      'creator' => ['Tove Jansson', 'Moomintroll'],
      'title' => 'Christmas in Moominvalley',
      'subject' => 'Moomin Papa',
      'identifier' => 'https://example.org/moomin/M00000000M1N',
      'date' => '2012-07-13T14:27:31Z',
      'language' => 'eng',
      'contributor' => [{ 'name' => 'Snorkmaiden',
                          'role' => 'Actor (leading role)' },
                        { 'name' => 'Snufkin',
                          'role' => 'Director' }],
      'translations' => { 'se' => 'Jul i Mumindalen',
                          'fi' => 'Muumilaakson joulu' }
    }

    content rec.to_json
  end

  factory :mods_record, parent: :krikri_original_record do
    content <<-EOS
<?xml version="1.0" encoding="UTF-8" ?>
<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
    <responseDate>2014-12-24T14:52:50Z</responseDate>
    <request metadataPrefix="mods" set="p261501coll8" verb="ListRecords">http://repox.metro.org:8080/repox/OAIHandler</request>
    <ListRecords>
        <record>
            <header>
                <identifier>oai:repox.ist.utl.pt:p261501coll8:oai:cdm16694.contentdm.oclc.org:p261501coll8/110</identifier>
                <datestamp>2014-10-08</datestamp>
                <setSpec>p261501coll8</setSpec>
            </header>
            <metadata>
                <mods version="3.4" xmlns="http://www.loc.gov/mods/v3" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">
                    <titleInfo>
                        <title>Valley with snow in spots, barns and houses can be seen</title>
                    </titleInfo>
                    <name>
                        <namePart>Franck Taylor Bowers</namePart>
                        <role>
                            <roleTerm>creator</roleTerm>
                        </role>
                    </name>
                    <physicalDescription>
                        <extent>5 X 7 inches</extent>
                    </physicalDescription>
                    <location>
                        <url access="object in context" usage="primary display">http://cdm16694.contentdm.oclc.org/cdm/ref/collection/p261501coll8/id/110</url>
                    </location>
                    <location>
                        <url access="preview">http://cdm16694.contentdm.oclc.org/utils/getthumbnail/collection/p261501coll8/id/110</url>
                    </location>
                    <accessCondition>This digital image may be used for one time personal use, as long as it is not altered in any way and proper credit is given that it is from the collection of the Broome County Historical Society. Prior written permission from the Broome County Historical Society is required for any other use of the images.</accessCondition>
                    <typeOfResource>still image</typeOfResource>
                    <note type="ownership">Broome County Public Library</note>
                </mods>
            </metadata>
            <about>
                <oaiProvenance:provenance xmlns:oaiProvenance="http://www.openarchives.org/OAI/2.0/provenance" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/provenance http://www.openarchives.org/OAI/2.0/provenance.xsd">
                    <oaiProvenance:originDescription altered="true" harvestDate="2014-10-08">
                        <oaiProvenance:baseURL>http://cdm16694.contentdm.oclc.org/oai/oai.php</oaiProvenance:baseURL>
                        <oaiProvenance:identifier>oai:cdm16694.contentdm.oclc.org:p261501coll8/110</oaiProvenance:identifier>
                        <oaiProvenance:datestamp>2014-10-08</oaiProvenance:datestamp>
                        <oaiProvenance:metadataNamespace>http://www.openarchives.org/OAI/2.0/</oaiProvenance:metadataNamespace>
                    </oaiProvenance:originDescription>
                </oaiProvenance:provenance>
            </about>
        </record>
    </ListRecords>
</OAI-PMH>
EOS
  end

  factory :marcxml_record, parent: :krikri_original_record do
    content <<-EOS
<?xml version="1.0" encoding="UTF-8" ?>
<?xml-stylesheet type="text/xsl" href="oai2.xsl" ?>
<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
<responseDate>2015-06-01T20:18:44Z</responseDate>
<request metadataPrefix="marc21" set="esbnd" verb="ListRecords">http://ufdc.ufl.edu/</request>
<ListRecords>
<record><header><identifier>oai:ufdc:UF00075496_00001</identifier><datestamp>2015-01-21</datestamp><setSpec>oai:ufdc:esbnd</setSpec></header><metadata><marc:record xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" type="Bibliographic">
<marc:leader>01414nkm  22003493a 4500</marc:leader>
<marc:controlfield tag="001">UF00075496_00001</marc:controlfield>
<marc:controlfield tag="005">20080904225003.0</marc:controlfield>
<marc:controlfield tag="006">m     o  c        </marc:controlfield>
<marc:controlfield tag="007">cr  n ---ma mp</marc:controlfield>
<marc:controlfield tag="008">070614n        xx nnn        o    neng d</marc:controlfield>
<marc:datafield tag="040" ind1=" " ind2=" ">
<marc:subfield code="a">FUG</marc:subfield>
<marc:subfield code="c">FUG</marc:subfield>
</marc:datafield>
<marc:datafield tag="245" ind1="0" ind2="0">
<marc:subfield code="a">The Everglades, Exploitation and Conservation</marc:subfield>
<marc:subfield code="h">[electronic resource].</marc:subfield>
</marc:datafield>
<marc:datafield tag="506" ind1=" " ind2=" ">
<marc:subfield code="a">Board of Trustees of the University of Florida on behalf of authors and contributors.  All rights reserved.</marc:subfield>
</marc:datafield>
<marc:datafield tag="533" ind1=" " ind2=" ">
<marc:subfield code="a">Electronic reproduction.</marc:subfield>
<marc:subfield code="b">Gainesville, Fla. :</marc:subfield>
<marc:subfield code="c">University of Florida, George A. Smathers Libraries,</marc:subfield>
<marc:subfield code="d">2007.</marc:subfield>
<marc:subfield code="f">(University of Florida Digital Collections)</marc:subfield>
<marc:subfield code="n">Mode of access: World Wide Web.</marc:subfield>
<marc:subfield code="n">System requirements: Internet connectivity; Web browser software.</marc:subfield>
</marc:datafield>
<marc:datafield tag="535" ind1="1" ind2=" ">
<marc:subfield code="a">University of Florida.</marc:subfield>
</marc:datafield>
<marc:datafield tag="536" ind1=" " ind2=" ">
<marc:subfield code="a">Funded by a grant from the Florida Humanities Council</marc:subfield>
</marc:datafield>
<marc:datafield tag="648" ind1=" " ind2=" ">
<marc:subfield code="a">1594-1920</marc:subfield>
<marc:subfield code="y">Spanish Colonial Period.</marc:subfield>
</marc:datafield>
<marc:datafield tag="648" ind1=" " ind2=" ">
<marc:subfield code="a">1594-1920</marc:subfield>
<marc:subfield code="y">Colonial Period.</marc:subfield>
</marc:datafield>
<marc:datafield tag="650" ind1=" " ind2="0">
<marc:subfield code="a">Saint Augustine (Fla.).</marc:subfield>
</marc:datafield>
<marc:datafield tag="650" ind1=" " ind2="0">
<marc:subfield code="a">Florida.</marc:subfield>
</marc:datafield>
<marc:datafield tag="651" ind1=" " ind2=" ">
<marc:subfield code="a">Spain</marc:subfield>
<marc:subfield code="z">America</marc:subfield>
<marc:subfield code="x">Colonies.</marc:subfield>
</marc:datafield>
<marc:datafield tag="700" ind1=" " ind2=" ">
<marc:subfield code="a">Florida Humanities Council.</marc:subfield>
</marc:datafield>
<marc:datafield tag="752" ind1=" " ind2=" ">
<marc:subfield code="a">United States of America</marc:subfield>
<marc:subfield code="b">Florida</marc:subfield>
<marc:subfield code="c">Saint Johns County</marc:subfield>
<marc:subfield code="d">Saint Augustine</marc:subfield>
<marc:subfield code="g">Historic city.</marc:subfield>
</marc:datafield>
<marc:datafield tag="752" ind1=" " ind2=" ">
<marc:subfield code="a">United States of America</marc:subfield>
<marc:subfield code="b">Florida.</marc:subfield>
</marc:datafield>
<marc:datafield tag="830" ind1=" " ind2="0">
<marc:subfield code="a">University of Florida Digital Collections.</marc:subfield>
</marc:datafield>
<marc:datafield tag="830" ind1=" " ind2="0">
<marc:subfield code="a">World Studies Collections.</marc:subfield>
</marc:datafield>
<marc:datafield tag="830" ind1=" " ind2="0">
<marc:subfield code="a">Spanish Borderlands Collections.</marc:subfield>
</marc:datafield>
<marc:datafield tag="830" ind1=" " ind2="0">
<marc:subfield code="a">Spanish Colonial St. Augustine.</marc:subfield>
</marc:datafield>
<marc:datafield tag="852" ind1=" " ind2=" ">
<marc:subfield code="a">SUS01:;:;:</marc:subfield>
<marc:subfield code="b">UFDC</marc:subfield>
<marc:subfield code="c">World Studies Collections</marc:subfield>
</marc:datafield>
<marc:datafield tag="856" ind1="4" ind2="0">
<marc:subfield code="u">http://ufdc.ufl.edu/UF00075496/00001</marc:subfield>
<marc:subfield code="y">Electronic Resource</marc:subfield>
</marc:datafield>
<marc:datafield tag="992" ind1="0" ind2="4">
<marc:subfield code="a">http://ufdcimages.uflib.ufl.edu/UF/00/07/54/96/00001/UF00075496_01thm.jpg</marc:subfield>
</marc:datafield>
<marc:datafield tag="997" ind1=" " ind2=" ">
<marc:subfield code="a">World Studies Collections</marc:subfield>
</marc:datafield>
</marc:record>
</metadata></record>
</ListRecords>
</OAI-PMH>
EOS
  end

  factory :primo_record, parent: :krikri_original_record do
    content <<-EOS
<sear:DOC xmlns:sear="http://www.exlibrisgroup.com/xsd/jaguar/search" ID="87209" RANK="1.0" NO="1" SEARCH_ENGINE="Local Search Engine" SEARCH_ENGINE_TYPE="Local Search Engine">
  <PrimoNMBib xmlns="http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib">
    <record>
      <control>
        <sourcerecordid>ui_ep/26178</sourcerecordid>
        <sourceid>digcoll_uid_36</sourceid>
        <recordid>digcoll_uid_36ui_ep/26178</recordid>
        <originalsourceid>26178</originalsourceid>
        <sourcedbandrecordid>ui_ep</sourcedbandrecordid>
        <addsrcrecordid>uid-36-289-2038</addsrcrecordid>
        <sourceformat>Digital Entity</sourceformat>
        <sourcesystem>Other</sourcesystem>
      </control>
      <display>
        <type>Text</type>
        <title>2011 Small Grain and Grain Legume Report</title>
        <creator>Finkelnburg, Doug</creator>
        <contributor>College of Agricultural and Life Sciences; University of Idaho Library</contributor>
        <publisher>Idaho Agricultural Experiment Station</publisher>
        <creationdate>2012</creationdate>
        <format>application/pdf</format>
        <identifier>http://digital.lib.uidaho.edu/cdm/ref/collection/ui_ep/id/26178</identifier>
        <subject>legumes; small cereal grains</subject>
        <description>From the Idaho Small Grain and Grain Legume Research and Extension Program at the University of Idaho comes this summary of the performance of winter wheat, spring wheat, spring barley, spring pea, lentil, and chickpea cultivars tested in Idaho, Lewis, Nez Perce, Latah, and Boundary counties in the 2010-11 crop season.</description>
        <language>eng</language>
        <relation>Is format of: Research Bulletin</relation>
        <relation>Is referenced by: 179</relation>
        <coverage>Idaho</coverage>
        <rights>Digital image copyright 2010, the University of Idaho. All rights reserved. For more information contact Special Collections and Archives, University of Idaho Library, Moscow, ID 83844-2350; http://www.lib.uidaho.edu/special-collections/.</rights>
        <lds01>University of Idaho Library</lds01>
        <lds02>University of Idaho Digital Collections</lds02>
        <lds03>University of Idaho Library</lds03>
        <lds04>Agricultural and Extension Publications</lds04>
        <lds08>Idaho</lds08>
        <lds12>Special Collections Idaho S 53 (Between E3 - E415)</lds12>
        <lds18>Text</lds18>
        <lds17>text</lds17>
      </display>
      <links>
        <linktorsrc>$$Tdigcoll_uid_36_linktores$$DOpen resource in a new window</linktorsrc>
        <thumbnail>$$Tdigcoll_uid_36_linktothumb$$DSee Thumbnail</thumbnail>
      </links>
      <search>
        <creatorcontrib>Finkelnburg, Doug</creatorcontrib>
        <creatorcontrib>College of Agricultural and Life Sciences; University of Idaho Library</creatorcontrib>
        <title>2011 Small Grain and Grain Legume Report</title>
        <description>From the Idaho Small Grain and Grain Legume Research and Extension Program at the University of Idaho comes this summary of the performance of winter wheat, spring wheat, spring barley, spring pea, lentil, and chickpea cultivars tested in Idaho, Lewis, Nez Perce, Latah, and Boundary counties in the 2010-11 crop season.</description>
        <subject>legumes; small cereal grains</subject>
        <sourceid>digcoll_uid_36</sourceid>
        <recordid>digcoll_uid_36ui_ep/26178</recordid>
        <creationdate>2012</creationdate>
        <addtitle>Is format of: Research Bulletin</addtitle>
        <addtitle>Is referenced by: 179</addtitle>
        <addsrcrecordid>uid-36-289-2038</addsrcrecordid>
        <scope>mw</scope>
        <lsr01>uid</lsr01>
        <lsr02>36</lsr02>
        <lsr03>289</lsr03>
        <lsr04>2038</lsr04>
        <lsr09>University of Idaho Library</lsr09>
        <lsr10>University of Idaho Digital Collections</lsr10>
        <lsr12>University of Idaho Library</lsr12>
        <lsr13>Agricultural and Extension Publications</lsr13>
        <lsr14>Idaho</lsr14>
        <rsrctype>text</rsrctype>
      </search>
      <sort>
        <title>2011 Small Grain and Grain Legume Report</title>
        <creationdate>2012</creationdate>
        <author>Finkelnburg, D</author>
      </sort>
      <facets>
        <language>eng</language>
        <creationdate>2012</creationdate>
        <topic>legumes</topic>
        <topic>small cereal grains</topic>
        <collection>Digital Collections</collection>
        <toplevel>online_resources</toplevel>
        <creatorcontrib>Finkelnburg, Doug</creatorcontrib>
        <format>application/pdf</format>
        <genre>unknown</genre>
        <lfc01>Agricultural and Extension Publications</lfc01>
        <lfc02>University of Idaho Library</lfc02>
        <lfc03>University of Idaho Library</lfc03>
        <lfc04>University of Idaho Digital Collections</lfc04>
        <lfc08>Idaho</lfc08>
        <prefilter>text</prefilter>
        <rsrctype>text</rsrctype>
        <frbrgroupid>237607336</frbrgroupid>
        <frbrtype>6</frbrtype>
      </facets>
      <delivery>
        <institution>MWDL</institution>
        <delcategory>Online Resource</delcategory>
      </delivery>
      <ranking>
        <booster1>1</booster1>
        <booster2>1</booster2>
      </ranking>
      <addata>
        <date>2012</date>
        <pub>Idaho Agricultural Experiment Station</pub>
      </addata>
    </record>
  </PrimoNMBib>
  <sear:GETIT deliveryCategory="Online Resource" GetIt1="http://digital.lib.uidaho.edu/u?/ui_ep,26178" GetIt2="http://sfx7.exlibrisgroup.com/uutah?ctx_ver=Z39.88-2004&amp;ctx_enc=info:ofi/enc:UTF-8&amp;ctx_tim=2015-11-19T16%3A46%3A32IST&amp;url_ver=Z39.88-2004&amp;url_ctx_fmt=infofi/fmt:kev:mtx:ctx&amp;rfr_id=info:sid/primo.exlibrisgroup.com:primo3-Journal-digcoll_uid_36&amp;rft_val_fmt=info:ofi/fmt:kev:mtx:&amp;rft.genre=&amp;rft.atitle=&amp;rft.jtitle=&amp;rft.btitle=&amp;rft.aulast=&amp;rft.auinit=&amp;rft.auinit1=&amp;rft.auinitm=&amp;rft.ausuffix=&amp;rft.au=&amp;rft.aucorp=&amp;rft.volume=&amp;rft.issue=&amp;rft.part=&amp;rft.quarter=&amp;rft.ssn=&amp;rft.spage=&amp;rft.epage=&amp;rft.pages=&amp;rft.artnum=&amp;rft.issn=&amp;rft.eissn=&amp;rft.isbn=&amp;rft.sici=&amp;rft.coden=&amp;rft_id=info:doi/&amp;rft.object_id=&amp;rft.eisbn=&amp;rft_dat=&lt;digcoll_uid_36&gt;ui_ep%2F26178&lt;/digcoll_uid_36&gt;&lt;grp_id&gt;237607336&lt;/grp_id&gt;&lt;oa&gt;&lt;/oa&gt;&amp;rft_id=info:oai/&amp;req.language=" />
  <sear:LINKS>
    <sear:linktorsrc>http://digital.lib.uidaho.edu/u?/ui_ep,26178</sear:linktorsrc>
    <sear:thumbnail>http://digital.lib.uidaho.edu/utils/getthumbnail/collection/ui_ep/id/26178</sear:thumbnail>
  </sear:LINKS>
</sear:DOC>
EOS
  end

end
