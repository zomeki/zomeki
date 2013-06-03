# encoding: utf-8
module ActiveModel
  class Errors
    def add_to_base(message)
      self[:base] << message
    end
  end
end

