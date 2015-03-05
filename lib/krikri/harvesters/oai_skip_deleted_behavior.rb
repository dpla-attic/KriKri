module Krikri::Harvesters
  ##
  # Harvest behavior that skips OAI records marked as deleted
  class OAISkipDeletedBehavior < BasicSaveBehavior
    def process_record
      return if deleted?(record)
      super
    end

    private

    def deleted?(record)
      header = Nokogiri::XML(record.content).xpath('//xmlns:header')
      return false if header.empty?
      status = header.first['status']
      return true if status.to_s.downcase.include? 'deleted'
      false
    end
  end
end
