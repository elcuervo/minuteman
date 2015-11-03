require 'ohm'
require 'securerandom'

module Minuteman
  class User < ::Ohm::Model
    attribute :uid
    attribute :identifier
    attribute :anonymous

    unique :uid
    unique :identifier

    index :anonymous

    def save
      self.uid ||= SecureRandom.uuid
      self.anonymous ||= !identifier
      super
    end

    def track(action, time = Time.now.utc)
      Minuteman.track(action, self, time)
    end

    def add(action, time = Time.now.utc)
      Minuteman.add(action, time, self)
    end

    def count(action, time = Time.now.utc)
      Minuteman::Analyzer.new(action, Minuteman::Counter::User, self)
    end

    def anonymous?
      self.anonymous == true
    end

    def promote(identifier)
      self.identifier = identifier
      self.anonymous = false
      save
    end

    def self.[](identifier_or_uuid)
      with(:uid, identifier_or_uuid) || with(:identifier, identifier_or_uuid)
    end
  end
end
