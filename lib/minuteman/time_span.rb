require 'minuteman/analyzable'

module Minuteman
  TimeSpan = Struct.new(:action, :key) do
    include Minuteman::Analyzable

    def self.day(action, time)
      new(action, time.strftime(Minuteman.patterns[:day]))
    end

    def count
      1
    end
  end
end
