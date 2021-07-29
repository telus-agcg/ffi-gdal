# frozen_string_literal: true

require 'ffi'
require_relative '../cpl/port'

module FFI
  module OGR
    module FieldTypes
      class IntegerList < FFI::Struct
        layout :count, :int,
               :list, :pointer
      end

      class Integer64List < FFI::Struct
        layout :count, FFI::CPL::Port.find_type(:GIntBig),
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
               :data, :pointer
      end

      class Set < FFI::Struct
        layout :marker1, :int,
               :marker2, :int
      end

      class Date < FFI::Struct
        layout :year, FFI::CPL::Port.find_type(:GInt16),
               :month, FFI::CPL::Port.find_type(:GByte),
               :day, FFI::CPL::Port.find_type(:GByte),
               :hour, FFI::CPL::Port.find_type(:GByte),
               :minute, FFI::CPL::Port.find_type(:GByte),
               :second, FFI::CPL::Port.find_type(:GByte),
               :tz_flag, FFI::CPL::Port.find_type(:GByte)
      end
    end

    class Field < FFI::Union
      include FieldTypes

      layout :integer, :int,
             :integer64, FFI::CPL::Port.find_type(:GIntBig),
             :real, :double,
             :string, :pointer,
             :integer_list, FieldTypes::IntegerList,
             :integer64_list, FieldTypes::Integer64List,
             :real_list, FieldTypes::RealList,
             :string_list, FieldTypes::StringList,
             :binary, FieldTypes::Binary,
             :set, FieldTypes::Set,
             :date, FieldTypes::Date
    end
  end
end
