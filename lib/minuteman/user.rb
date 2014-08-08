require 'ohm'
require 'securerandom'

module Minuteman
  class User < Ohm::Model
    attribute :uid
    attribute :identifier

    def save
      self.uid ||= SecureRandom.uuid
      super
    end
  end
end
