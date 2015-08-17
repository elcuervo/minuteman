require 'minuteman'
require 'minuteman/analyzable'

module Minuteman
  TimeSpan = Struct.new(:action, :key) do
    include Minuteman::Analyzable

    class << self
      Minuteman.patterns.each do |k, v|
        define_method(k) do
          new(action, Minuteman.patterns[k].call(time))
        end
      end
    end

    def count
      1
    end
  end
end
