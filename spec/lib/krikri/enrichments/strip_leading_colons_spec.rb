require 'spec_helper'

describe Krikri::Enrichments::StripLeadingColons do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes (semi)colons from beginning of field',
              :start => ";:\tmoominpa()pa;;;",
              :end => "\tmoominpa()pa;;;"
            },
            { :string => 'leaves other fields unaltered',
              :start => ";:\tmoominpapa;:;:; moominmama! ...\n",
              :end => "\tmoominpapa;:;:; moominmama! ...\n"
            }]

  it_behaves_like 'a string enrichment', values
end
