module OGR
  module LayerMixins
    module OGRSQLMethods
      # @return [Boolean]
      def start_transaction
        transact { FFI::OGR::API.OGR_L_StartTransaction(@c_pointer) }
      end

      # @return [Boolean]
      def commit_transaction
        transact { FFI::OGR::API.OGR_L_CommitTransaction(@c_pointer) }
      end

      # @return [Boolean]
      def rollback_transaction
        transact { FFI::OGR::API.OGR_L_RollbackTransaction(@c_pointer) }
      end

      # The name of the underlying database column or "" if not supported.
      #
      # @return [String]
      def fid_column
        FFI::OGR::API.OGR_L_GetFIDColumn(@c_pointer)
      end

      # The name of the underlying database column being used as the geometry
      # column.  Returns "" if not supported.
      #
      # @return [String]
      def geometry_column
        FFI::OGR::API.OGR_L_GetGeometryColumn(@c_pointer)
      end

      private

      # @return [Boolean]
      def transact
        unless supports_transactions?
          fail OGR::UnsupportedOperation, 'This layer does not support transactions.'
        end

        ogr_err = yield

        ogr_err.handle_result
      end
    end
  end
end
