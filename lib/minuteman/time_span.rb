module Minuteman
  TimeSpan = Struct.new(:action, :pattern) do
    def count
      1
    end
  end
end
