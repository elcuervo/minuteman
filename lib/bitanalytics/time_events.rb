require "bitanalytics/time_span"
require "bitanalytics/month"

class BitAnalytics
  module TimeEvents
    def self.start(redis, event_name, time)
      [Month].map { |t| t.new(redis, event_name, time) }
    end
  end
end
