module Krikri::Harvesters
  ##
  # A harvester for MDL's API
  class MdlHarvester < ApiHarvester
    def initialize(opts = {})
      opts[:uri] ||= 'http://hub-client.lib.umn.edu/api/v1/records'
      opts[:name] ||= 'mdl'
      super
      @opts['params'] ||= { 'q' => 'tags_ssim:dpla' }
    end
  end
end
