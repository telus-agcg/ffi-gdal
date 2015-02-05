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
    end
  end
end
