# frozen_string_literal: true

class Integer
  def to_bool
    return true if self == 1
    return false if zero?

    raise "Integer '#{self}' can't be converted to Boolean."
  end
end

class String
  def to_bool
    return true if self == "\x01" || self == "1"
    return false if self == "\x00" || self == "0"

    raise "String '#{self}' can't be converted to Boolean."
  end
end
