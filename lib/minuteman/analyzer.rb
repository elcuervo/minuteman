require 'minuteman/event'

module Minuteman
  class Analyzer
    def initialize(action, klass = Minuteman::Event)
      @action = action

      Minuteman.patterns.keys.each do |method|
        define_singleton_method(method) do |time = Time.now.utc|
          if !Minuteman.patterns.include?(method)
            raise MissingPattern.new(method)
          end

          key = Minuteman.patterns[method].call(time)
          klass.find_or_create(type: action, time: key)
        end
      end
    end
  end

end
