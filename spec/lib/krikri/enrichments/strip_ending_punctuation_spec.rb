require 'spec_helper'

describe Krikri::Enrichments::StripEndingPunctuation do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes punctuation from end of field',
              :start => "moomin!...!;,.",
              :end => "moomin"
            },
            { :string => 'keeps initials',
              :start => "Smith, Smithy Q.",
              :end => "Smith, Smithy Q."
            },
            { :string => 'keeps closing parentheses',
              :start => "(Smith)",
              :end => "(Smith)"
            },
            { :string => 'keeps two letter abbreviations',
              :start => "66 cm.",
              :end => "66 cm."
            },
            { :string => 'leaves other fields unaltered',
              :start => "moominpapa;:;:; moominmama",
              :end => "moominpapa;:;:; moominmama"
            }]

  it_behaves_like 'a string enrichment', values
end
