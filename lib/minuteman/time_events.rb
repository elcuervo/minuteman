require "minuteman/time_spans"

class Minuteman
  module TimeEvents
    # Public: Helper to get all the time trakers ready
    #
    #   redis      - The Redis connection
    #   event_name - The event to be tracked
    #   date       - A given Time object
    #
    def self.start(redis, event_name, time)
      [Year, Month, Week, Day, Hour, Minute].map do |t|
        t.new(redis, event_name, time)
      end
    end
  end
end
