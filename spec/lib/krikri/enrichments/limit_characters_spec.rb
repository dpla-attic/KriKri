# -*- coding: utf-8 -*-
require 'spec_helper'

describe Krikri::Enrichments::LimitCharacters do
  it_behaves_like 'a field enrichment'

  values = [{ :string => 'truncates a string over 1000 characters',
              # The following string has 1022 characters.
              :start => 'Lorem ipsum dolor sit amet, consectetur adipiscing '\
              'elit. Praesent tellus felis, porttitor non nulla ut, tincidunt '\
              'eleifend lacus. Mauris sit amet urna sed mi dapibus hendrerit '\
              'luctus sed metus. Nullam ut magna iaculis, gravida mauris sed, '\
              'cursus sapien. Duis in libero tellus. Donec ac mollis dolor, '\
              'convallis elementum lacus. Nullam vitae sodales nisl. Proin '\
              'sed neque leo. Interdum et malesuada fames ac ante ipsum '\
              'primis in faucibus. Aenean quis tortor in purus vehicula '\
              'convallis. Suspendisse finibus cursus venenatis. Nam ac arcu '\
              'in urna maximus dictum. Phasellus tempor tincidunt lectus '\
              'aliquam eleifend. Morbi in commodo massa, sit amet bibendum '\
              'quam. Sed efficitur velit libero, nec pulvinar diam tempor a. '\
              'In eu ullamcorper risus, non pretium felis. Nam rutrum augue '\
              'vel quam lacinia, non feugiat nunc fermentum. Aliquam lacinia '\
              'rutrum lorem sed commodo. Nam tempor vel nisl eget vestibulum. '\
              'Nunc lorem velit, euismod a ipsum non, consequat vulputate '\
              'tellus. Phasellus sapien ipsum portal vitae augue eu volutpat.',
              # The following string has 1000 characters (including elipse).
              :end => 'Lorem ipsum dolor sit amet, consectetur adipiscing '\
              'elit. Praesent tellus felis, porttitor non nulla ut, tincidunt '\
              'eleifend lacus. Mauris sit amet urna sed mi dapibus hendrerit '\
              'luctus sed metus. Nullam ut magna iaculis, gravida mauris sed, '\
              'cursus sapien. Duis in libero tellus. Donec ac mollis dolor, '\
              'convallis elementum lacus. Nullam vitae sodales nisl. Proin '\
              'sed neque leo. Interdum et malesuada fames ac ante ipsum '\
              'primis in faucibus. Aenean quis tortor in purus vehicula '\
              'convallis. Suspendisse finibus cursus venenatis. Nam ac arcu '\
              'in urna maximus dictum. Phasellus tempor tincidunt lectus '\
              'aliquam eleifend. Morbi in commodo massa, sit amet bibendum '\
              'quam. Sed efficitur velit libero, nec pulvinar diam tempor a. '\
              'In eu ullamcorper risus, non pretium felis. Nam rutrum augue '\
              'vel quam lacinia, non feugiat nunc fermentum. Aliquam lacinia '\
              'rutrum lorem sed commodo. Nam tempor vel nisl eget vestibulum. '\
              'Nunc lorem velit, euismod a ipsum non, consequat vulputate '\
              'tellus. Phasellus sapien ipsum portal...'
            },
            { :string => 'truncates at whitespace',
              # The following string has 1023 characters.
              :start => 'Lorem ipsum dolor sit amet, consectetur adipiscing '\
              'elit. Praesent tellus felis, porttitor non nulla ut, tincidunt '\
              'eleifend lacus. Mauris sit amet urna sed mi dapibus hendrerit '\
              'luctus sed metus. Nullam ut magna iaculis, gravida mauris sed, '\
              'cursus sapien. Duis in libero tellus. Donec ac mollis dolor, '\
              'convallis elementum lacus. Nullam vitae sodales nisl. Proin '\
              'sed neque leo. Interdum et malesuada fames ac ante ipsum '\
              'primis in faucibus. Aenean quis tortor in purus vehicula '\
              'convallis. Suspendisse finibus cursus venenatis. Nam ac arcu '\
              'in urna maximus dictum. Phasellus tempor tincidunt lectus '\
              'aliquam eleifend. Morbi in commodo massa, sit amet bibendum '\
              'quam. Sed efficitur velit libero, nec pulvinar diam tempor a. '\
              'In eu ullamcorper risus, non pretium felis. Nam rutrum augue '\
              'vel quam lacinia, non feugiat nunc fermentum. Aliquam lacinia '\
              'rutrum lorem sed commodo. Nam tempor vel nisl eget vestibulum. '\
              'Nunc lorem velit, euismod a ipsum non, consequat vulputate '\
              'tellus. Phasellus sapien ipsum portale vitae augue eu volutpat.',
              # The following string has 993 characters (including elipse).
              :end => 'Lorem ipsum dolor sit amet, consectetur adipiscing '\
              'elit. Praesent tellus felis, porttitor non nulla ut, tincidunt '\
              'eleifend lacus. Mauris sit amet urna sed mi dapibus hendrerit '\
              'luctus sed metus. Nullam ut magna iaculis, gravida mauris sed, '\
              'cursus sapien. Duis in libero tellus. Donec ac mollis dolor, '\
              'convallis elementum lacus. Nullam vitae sodales nisl. Proin '\
              'sed neque leo. Interdum et malesuada fames ac ante ipsum '\
              'primis in faucibus. Aenean quis tortor in purus vehicula '\
              'convallis. Suspendisse finibus cursus venenatis. Nam ac arcu '\
              'in urna maximus dictum. Phasellus tempor tincidunt lectus '\
              'aliquam eleifend. Morbi in commodo massa, sit amet bibendum '\
              'quam. Sed efficitur velit libero, nec pulvinar diam tempor a. '\
              'In eu ullamcorper risus, non pretium felis. Nam rutrum augue '\
              'vel quam lacinia, non feugiat nunc fermentum. Aliquam lacinia '\
              'rutrum lorem sed commodo. Nam tempor vel nisl eget vestibulum. '\
              'Nunc lorem velit, euismod a ipsum non, consequat vulputate '\
              'tellus. Phasellus sapien ipsum...'
            },
            { :string => 'leaves strings under 1000 characters alone',
              :start => 'Lorem ipsum dolor sit amet',
              :end => 'Lorem ipsum dolor sit amet'
            },
            { :string => 'leaves other values alone',
              :start => ['array of strings'],
              :end => ['array of strings']
            }]

  it_behaves_like 'a string enrichment', values
  include_examples 'skips non-strings'
end
