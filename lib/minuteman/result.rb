require 'minuteman/analyzable'

module Minuteman
  Result = Struct.new(:key) do
    include Minuteman::Analyzable
  end
end
