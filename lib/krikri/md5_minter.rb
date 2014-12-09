module Krikri
  module Md5Minter
    def self.create(id, prefix = nil)
      id = add_prefix(prefix.to_s, id) unless prefix.nil?
      Digest::MD5.hexdigest(id)
    end

    private

    def self.add_prefix(source, id)
      "#{source}--#{id.strip.gsub(' ', '__')}"
    end
  end
end
