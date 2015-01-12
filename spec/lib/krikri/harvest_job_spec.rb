require 'spec_helper'

describe Krikri::HarvestJob do
  it_behaves_like 'a job', Krikri::Harvester do
    before do
      expect_any_instance_of(Krikri::Harvester)
        .to receive(:run)
        .and_return(true)
    end
  end
end
