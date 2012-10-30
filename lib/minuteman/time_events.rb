require "minuteman/time_spans"

class Minuteman
  module TimeEvents
    def self.start(redis, event_name, time)
      [Year, Month, Week, Day, Hour, Minute].map do |t|
        t.new(redis, event_name, time)
      end
    end
  end
end
