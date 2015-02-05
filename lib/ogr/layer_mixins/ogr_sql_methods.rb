module OGR
  module LayerMixins
    module OGRSQLMethods
      # @return [Boolean]
      def start_transaction
        ogr_err = FFI::GDAL.OGR_L_StartTransaction(@layer_pointer)

        ogr_err.handle_result
      end

      # @return [Boolean]
      def commit_transaction
        ogr_err = FFI::GDAL.OGR_L_CommitTransaction(@layer_pointer)

        ogr_err.handle_result
      end

      # @return [Boolean]
      def rollback_transaction
        ogr_err = FFI::GDAL.OGR_L_RollbackTransaction(@layer_pointer)

        ogr_err.handle_result
      end

      # The name of the underlying database column or "" if not supported.
      #
      # @return [String]
      def fid_column
        FFI::GDAL.OGR_L_GetFIDColumn(@layer_pointer)
      end

      # The name of the underlying database column being used as the geometry
      # column.  Returns "" if not supported.
      #
      # @return [String]
      def geometry_column
        FFI::GDAL.OGR_L_GetGeometryColumn(@layer_pointer)
      end
    end
  end
end
