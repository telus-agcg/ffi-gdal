# frozen_string_literal: true

require_relative '../ffi-gdal'

module FFI
  module CPL
    extend FFI::InternalHelpers

    autoload :Conv,     autoload_path('cpl/conv.rb')
    autoload :Error,    autoload_path('cpl/error.rb')
    autoload :HashSet,  autoload_path('cpl/hash_set.rb')
    autoload :HTTP,     autoload_path('cpl/http.rb')
    autoload :MiniXML,  autoload_path('cpl/minixml.rb')
    autoload :Port,     autoload_path('cpl/port.rb')
    autoload :Progress, autoload_path('cpl/progress.rb')
    autoload :QuadTree, autoload_path('cpl/quad_tree.rb')
    autoload :String,   autoload_path('cpl/string.rb')
    autoload :VSI,      autoload_path('cpl/vsi.rb')
    autoload :XMLNode,  autoload_path('cpl/xml_node.rb')
  end
end
