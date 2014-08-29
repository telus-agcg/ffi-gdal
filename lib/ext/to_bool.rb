class Fixnum
  def to_bool
    return true if self == 1
    return false if self == 0
  end
end

class String
  def to_bool
    return true if self.to_i == 1
    return false if self.to_i == 0
  end
end
