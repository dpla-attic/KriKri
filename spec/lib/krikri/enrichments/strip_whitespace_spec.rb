require 'spec_helper'

describe Krikri::Enrichments::StripWhitespace do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes extra whitespace from fields',
              :start => "\tmoominpapa  \t\r  \nmoominmama  ",
              :end => 'moominpapa moominmama'
            },
            { :string => 'leaves other fields unaltered',
              :start => 'moominpapa moominmama',
              :end => 'moominpapa moominmama'
            }]

  it_behaves_like 'a string enrichment', values
  include_examples 'skips non-strings'
end
