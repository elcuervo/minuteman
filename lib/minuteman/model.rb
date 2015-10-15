require 'ohm'

module Minuteman
  class Model < ::Ohm::Model
    attribute :type
    attribute :time

    def self.find(*args)
      looked_up = "#{self.class}::#{args.first[:type]}:#{args.first[:time]}:id"
      potential_id = Minuteman.config.redis.call("GET", looked_up)
      self[potential_id]
    end

    def self.find_or_create(*args)
      find(*args) || create(*args)
    end

    def self.create(*args)
      event = super(*args)
      Minuteman.config.redis.call("SET", "#{event.key}:id", event.id)
      event
    end

    def key
      "#{self.class}::#{type}:#{time}"
    end

  end
end
