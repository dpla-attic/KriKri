require 'spec_helper'

describe Krikri::Enrichments::ParseDate do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'parses calendar to ruby Date',
              :start => 'May 15, 2014',
              :end => Date.parse('2014-05-15')
            },
            { :string => 'parses ISO to ruby Date',
              :start => '2014-05-15',
              :end => Date.parse('2014-05-15')
            },
            { :string => 'parses slash to ruby Date',
              :start => '5/7/2012',
              :end => Date.parse('2012-05-07')
            },
            { :string => 'parses dot to ruby Date',
              :start => '5.7.2012',
              :end => Date.parse('2012-05-07')
            },
            { :string => 'parses Month, Year to ruby Date',
              :start => 'July, 2015',
              :end => Date.parse('2015-07-01')
            },
            { :string => 'parses M-D-Y to ruby Date',
              :start => '12-19-2010',
              :end => Date.parse('2010-12-19')
            },
            { :string => 'parses uncertain to EDTF',
              :start => '2015?',
              :end => Date.edtf('2015?')
            },
            { :string => 'leaves other fields unaltered',
              :start => "moominpapa",
              :end => "moominpapa"
            }]

  it_behaves_like 'a string enrichment', values
end
