require 'spec_helper'

describe Krikri::Enrichments::ConvertToSentenceCase do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'converts to sentence case',
              :start => 'moomin. snORKmaiden! HATTIFATTENERS? the Groak.',
              :end => 'Moomin. Snorkmaiden! Hattifatteners? The groak.'
            },
            { :string => 'leaves other fields unaltered',
              :start => 'Blah blah blah',
              :end => 'Blah blah blah'
            }]

  it_behaves_like 'a string enrichment', values
end
