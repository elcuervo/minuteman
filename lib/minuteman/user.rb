require 'ohm'
require 'securerandom'

require 'minuteman/model'

module Minuteman
  class User < Minuteman::Model
    attribute :uid
    attribute :identifier

    index :uid
    index :identifier

    def save
      self.uid ||= SecureRandom.uuid
      super
    end

    def self.[](id_uid)
      super(id_uid) || find(uid: id_uid).first
    end
  end
end
