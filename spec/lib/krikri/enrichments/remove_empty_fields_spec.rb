require 'spec_helper'

describe Krikri::Enrichments::RemoveEmptyFields do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes empty fields',
              :start => '',
              :end => nil
            },
            { :string => 'removes whitespace only fields',
              :start => '   ',
              :end => nil
            },
            { :string => 'removes whitespace only fields with newlines',
              :start => "\n\t  \t\n",
              :end => nil
            },

            { :string => 'keeps whitespace heavy fields with newlines',
              :start => "\n\t value \t\n",
              :end => "\n\t value \t\n"
            },
            { :string => 'leaves non-empty fields unaltered',
              :start => 'moomin',
              :end => 'moomin'
            }]

  it_behaves_like 'a string enrichment', values
  include_examples 'skips non-strings'
end
