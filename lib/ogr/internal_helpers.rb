module OGR
  module InternalHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def _boolean_access_flag(flag)
        case flag
        when 'w' then true
        when 'r' then false
        else fail "Invalid access_flag '#{access_flag}'.  Use 'r' or 'w'."
        end
      end
    end
  end
end
