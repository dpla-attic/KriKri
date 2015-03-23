require 'spec_helper'

describe Krikri::Enrichments::StripLeadingPunctuation do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes punctuation from beginning of field',
              :start => "([!.;:\tmoominpapa;:;:; moominmama! ...\n",
              :end => "\tmoominpapa;:;:; moominmama! ...\n"
            },
            { :string => 'leaves other fields unaltered',
              :start => "'moominpapa;:;:; moominmama! ...\n'",
              :end => "'moominpapa;:;:; moominmama! ...\n'"
            }]

  it_behaves_like 'a string enrichment', values
end
