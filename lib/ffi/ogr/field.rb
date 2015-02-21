require_relative '../cpl/conv'

module FFI
  module OGR
    module FieldTypes
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
        layout :year, FFI::CPL::Conv.find_type(:GInt16),
          :month, FFI::CPL::Conv.find_type(:GByte),
          :day, FFI::CPL::Conv.find_type(:GByte),
          :hour, FFI::CPL::Conv.find_type(:GByte),
          :minute, FFI::CPL::Conv.find_type(:GByte),
          :second, FFI::CPL::Conv.find_type(:GByte),
          :tz_flag, FFI::CPL::Conv.find_type(:GByte)
      end
    end

    class Field < FFI::Union
      include FieldTypes

      layout :integer, :int,
        :real, :double,
        :string, :string,
        :integer_list, FieldTypes::IntegerList,
        :real_list, FieldTypes::RealList,
        :string_list, FieldTypes::StringList,
        :binary, FieldTypes::Binary,
        :set, FieldTypes::Set,
        :date, FieldTypes::Date
    end
  end
end
