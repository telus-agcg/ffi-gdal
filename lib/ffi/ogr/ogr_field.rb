module FFI
  module GDAL
    class IntegerList < FFI::Struct
      layout :count, :int,
        :list, :pointer
    end

    class RealList < FFI::Struct
      layout :count, :int,
        :list, :pointer
    end

    class StringList < FFI::Struct
      layout :count, :int,
        :list, :pointer
    end

    class Binary < FFI::Struct
      layout :count, :int,
        :list, :pointer
    end

    class Set < FFI::Struct
      layout :marker1, :int,
        :marker2, :int
    end

    class Date < FFI::Struct
      layout :year, :GInt16,
        :month, :GByte,
        :day, :GByte,
        :hour, :GByte,
        :minute, :GByte,
        :second, :GByte,
        :tz_flag, :GByte
    end

    class OGRField < FFI::Union
      layout :integer, :int,
        :real, :double,
        :string, :string,
        :integer_list, IntegerList,
        :real_list, RealList,
        :string_list, StringList,
        :binary, Binary,
        :set, Set,
        :date, Date
    end
  end
end
