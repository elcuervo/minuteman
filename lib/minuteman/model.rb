require 'ohm'
require 'nido'

module Minuteman
  class Model < ::Ohm::Model
    def self.key
      Nido.new(:minuteman)[self.name]
    end
  end
end
