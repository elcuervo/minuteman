module Minuteman
  Event = Struct.new(:action, :key) do
    def id
      @_id ||= "#{self.class}:#{action}_#{key}"
    end
  end
end
