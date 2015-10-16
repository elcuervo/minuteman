require 'minuteman/configuration'
require 'minuteman/analyzable'

module Minuteman
  Result = Struct.new(:key) do
    include Minuteman::Analyzable

    def id
      @_id ||= "(#{key.gsub(Minuteman.config.operations_prefix, "")})"
    end
  end
end
