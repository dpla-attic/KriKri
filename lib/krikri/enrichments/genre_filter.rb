module Krikri::Enrichments
  ##
  # Enrichment to remove non-genre fields from
  #
  #   StripHtml.new.enrich_value('Book') => 'Book'
  #   StripHtml.new.enrich_value('not a book') => nil
  #
  # Allowed genre terms are:
  #
  #  - Book
  #  - Film/Video
  #  - Manuscript
  #  - Maps
  #  - Music
  #  - Musical Score
  #  - Newspapers
  #  - Nonmusic
  #  - Photograph/Pictorial Works
  #  - Serial
  #
  # Removes all non-string values
  class GenreFilter
    include Krikri::FieldEnrichment

    TERMS = ['Book',
             'Film/Video',
             'Manuscript',
             'Maps',
             'Music',
             'Musical Score',
             'Newspapers',
             'Nonmusic',
             'Photograph/Pictorial Works',
             'Serial']

    def enrich_value(value)
      return nil unless value.is_a? String
      term = TERMS.select do |t|
        t.downcase.gsub(/[^a-zA-Z]/, '') ==
          value.downcase.gsub(/[^a-zA-Z]/, '')
      end
      term.empty? ? nil : term.first
    end
  end
end
