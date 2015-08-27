module Minuteman
  Event = Struct.new(:action, :key) do
    def to_s
      @_to_s ||= "#{self.class}:#{action}_#{key}"
    end
  end
end
