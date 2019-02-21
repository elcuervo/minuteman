require "ohm"
require "nest"

module Minuteman
  class Model < ::Ohm::Model
    attribute :type
    attribute :time

    def self.find(*args)
      looked_up = "#{self.name}::#{args.first[:type]}:#{args.first[:time]}:id"
      potential_id = Minuteman.config.redis.call("GET", looked_up)

      return nil if !potential_id

      event = self[potential_id]
      event.type = args.first[:type]
      event.time = args.first[:time]

      event
    end

    def self.find_or_create(*args)
      find(*args) || create(*args)
    end

    def self.create(*args)
      event = super(*args)
      Minuteman.config.redis.call("SADD", "#{Minuteman.prefix}::Events", event.type)
      Minuteman.config.redis.call("SET", "#{event.key}:id", event.id)

      event
    end

    def key
      Nest.new("#{self.class.name}::#{type}:#{time}", Minuteman.config.redis)
    end
  end
end
