module Krikri
  module PrettifierHelperBehavior
    def prettify_json_string(string)
      begin
        return JSON.pretty_generate(JSON.parse(string))
      rescue JSON::ParserError
        return string
      end
    end

    def prettify_xml_string(string)
      if Nokogiri.XML(string).errors.empty?
        doc = Nokogiri.XML(string) { |c| c.noblanks }
        return doc.to_xml(indent: 2)
      end
      string
    end
  end
end