require 'minuteman/event'

module Minuteman
  class Analyzer
    def initialize(action)
      @action = action

      Minuteman.patterns.keys.each do |method|
        define_singleton_method(method) do |time = Time.now.utc|
          if !Minuteman.patterns.include?(method)
            raise MissingPattern.new(method)
          end

          key = Minuteman.patterns[method].call(time)
          Minuteman::Event.find_or_create(type: action, time: key)
        end
      end
    end
  end

end
