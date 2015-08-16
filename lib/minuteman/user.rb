require 'ohm'
require 'securerandom'

require 'minuteman/model'

module Minuteman
  class User < Minuteman::Model
    attribute :uid
    attribute :identifier

    unique :uid
    unique :identifier

    def save
      self.uid ||= SecureRandom.uuid
      super
    end

    def promote(identifier)
      self.identifier = identifier
      save
    end

    def self.[](identifier_or_uuid)
      with(:uid, identifier_or_uuid) || with(:identifier, identifier_or_uuid)
    end
  end
end
