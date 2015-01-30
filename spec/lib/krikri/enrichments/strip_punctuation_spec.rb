require 'spec_helper'

describe Krikri::Enrichments::StripPunctuation do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes punctuation from fields',
              :start => "\tmoominpapa;... !@#$ moominmama  ",
              :end => "\tmoominpapa  moominmama  "
            },
            { :string => 'leaves other fields unaltered',
              :start => "\tmoominpapa moominmama",
              :end => "\tmoominpapa moominmama"
            }]
  it_behaves_like 'a string enrichment', values
  include_examples 'skips non-strings'
end
