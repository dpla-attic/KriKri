# -*- coding: utf-8 -*-
require 'spec_helper'

describe Krikri::Enrichments::StripHtml do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'removes html tags from fields',
              :start => '<html>Moomin <i><b>Valley</i></b>',
              :end => 'Moomin Valley'
            },
            { :string => 'leaves unicode chars',
              :start => '<i>Muminfamiljen</i> ska ge sig ut på skattjakt',
              :end => 'Muminfamiljen ska ge sig ut på skattjakt'
            },
            { :string => 'leaves other values alone',
              :start => 'Muminfamiljen ska ge sig ut på skattjakt',
              :end => 'Muminfamiljen ska ge sig ut på skattjakt'
            }]

  it_behaves_like 'a string enrichment', values
  include_examples 'skips non-strings'
end
