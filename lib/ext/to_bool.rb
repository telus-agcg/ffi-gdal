class Fixnum
  def to_bool
    return true if self == 1
    return false if self == 0
    fail "Fixnum '#{self}' can't be converted to Boolean."
  end
end

class String
  def to_bool
    return true if to_i == 1
    return false if to_i == 0
    fail "String '#{self}' can't be converted to Boolean."
  end
end
