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
end
