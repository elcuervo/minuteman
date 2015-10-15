require 'minuteman/analyzable'

module Minuteman
  Result = Struct.new(:id, :key) do
    include Minuteman::Analyzable
  end
end
