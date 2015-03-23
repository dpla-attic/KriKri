require 'spec_helper'

describe Krikri::Enrichments::GenreFilter do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes non-genre terms',
              :start => 'Not A Term',
              :end => nil
            },
            { :string => 'retains genre terms',
              :start => 'Book',
              :end => 'Book'
            },
            { :string => 'normalizes string form',
              :start => "\n bO  O-k!   \t",
              :end => 'Book'
            }]

  it_behaves_like 'a string enrichment', values
  include_examples 'deletes non-strings'
end
