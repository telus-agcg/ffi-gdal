require_relative '../ffi/gdal/alg'

module GDAL
  class Transformer
    # @return [FFI::Pointer]
    def self.create_similar_transformer(transformer_arg_ptr, source_ratio_x, source_ratio_y)
      FFI::GDAL::Alg.GDALCreateSimilarTransformer(transformer_arg_ptr, source_ratio_x, source_ratio_y)
    end

    # @param [FFI::Pointer]
    def self.destroy_transformer(transformer_arg)
      FFI::GDAL::Alg.GDALDestroyTransformer(transformer_arg)
    end

    # @param base_transformer_function [Proc]
    # @param transformer_arg_ptr [FFI::Pointer]
    # @param max_error [Float] The maximum cartesian error in the "output" space
    #   that will be accepted in the linear approximation.
    def self.create_approx_transformer(base_transformer_function, transformer_arg_ptr, max_error)
      FFI::GDAL::Alg.GDALCreateApproxTransformer(
        base_transformer_function,
        transformer_arg_ptr,
        max_error)
    end

    # @param callback_data [FFI::Pointer]
    def self.destroy_approx_transformer(callback_data)
      FFI::GDAL::Alg.GDALDestroyApproxTransformer(callback_data)
    end

    # @param gcp_list [Array<FFI::GDAL::GCP>]
    # @param requested_polynomial_order [Fixnum] 1, 2, or 3.
    # @param reversed [Boolean]
    # @return [FFI::Pointer]
    def self.create_gcp_transformer(gcp_list, requested_polynomial_order, reversed = false)
      gcp_list_ptr = FFI::MemoryPointer.new(:pointer, gcp_list.size)

      gcp_list.each_with_index do |gcp, i|
        gcp_list_ptr[i].put_pointer(0, gcp.to_ptr)
      end

      transform_agr_ptr = FFI::GDAL::Alg.GDALCreateGCPTransformer(
        gcp_list.size,
        gcp_list_ptr,
        requested_polynomial_order,
        reversed)

      ObjectSpace.define_finalizer(transform_agr_ptr) do
        destroy_gcp_transformer(transform_agr_ptr)
      end

      transform_agr_ptr
    end

    # @param transform_argument [FFI::Pointer]
    def self.destroy_gcp_transformer(transform_argument)
      FFI::GDAL::Alg.GDALDestroyGCPTransformer(transform_argument)
    end

    # @param source_dataset [GDAL::Dataset, FFI::Pointer]
    # @param source_wkt [String]
    # @param destination_dataset [GDAL::Dataset, FFI::Pointer]
    # @param destination_wkt [String]
    # @return [FFI::Pointer]
    def self.create_gen_img_proj_transformer(source_dataset, source_wkt,
      destination_dataset, destination_wkt,
      gcp_use_ok: false, gcp_error_threshold: 0, order: 1)
      source_ptr = GDAL._pointer(GDAL::Dataset, source_dataset)
      dest_ptr = GDAL._pointer(GDAL::Dataset, destination_dataset)

      transformer_ptr = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer(
        source_ptr,
        source_wkt,
        dest_ptr,
        destination_wkt,
        gcp_use_ok,
        gcp_error_threshold,
        order
      )

      ObjectSpace.define_finalizer(transformer_ptr) do
        destroy_gen_img_proj_transformer(transformer_ptr)
      end

      transformer_ptr
    end

    # @param source_dataset [GDAL::Dataset, FFI::Pointer]
    # @param destination_dataset [GDAL::Dataset, FFI::Pointer]
    # @param options [Hash]
    # @option options [String] src_srs Use to override +source_dataset+'s WKT
    #   SRS.
    # @option options [String] dst_srs Use to override +destination_dataset+'s WKT
    #   SRS.
    # @option options [Boolean] gcps_ok (true)
    # @option options [Fixnum] refine_minimum_gcps Minimum amount of GCPs that
    #   should be available after the refinement.
    # @option options [Float] refine_tolerance The tolerance that specifies
    #   when a GCP will be eliminated.
    # @option options [Fixnum] max_gcp_order Max order to use for GCP-derived
    #   polynomials, if possible. Default is to auto-select based on the number
    #   of GCPs. A value of -1 triggers use of Thin Plate Spline instead of
    #   polynomials.
    # @option options [String] src_method GEOTRANSFORM, GCP_POLYNOMIAL, GCP_TPS,
    #   GEOLOC_ARRAY, or RPC. Use this specific geolocation method when
    #   transforming pixel/line to georeferenced space on the source dataset.
    # @option options [String] dst_method GEOTRANSFORM, GCP_POLYNOMIAL, GCP_TPS,
    #   GEOLOC_ARRAY, or RPC. Use this specific geolocation method when
    #   transforming pixel/line to georeferenced space on the destination
    #   dataset.
    # @option options [Float] rpc_height A fixed height to be used with RPC
    #   calculations.
    # @option options [String] rpc_dem Name of a DEM file to be used with RPC
    #   calculations.
    # @option options [Boolean] insert_center_long (true) False disables setting
    #   up a CENTER_LONG value on the coordinate system to rewrap things around
    #   the center of the image.
    def self.create_gen_img_proj_transformer2(source_dataset, destination_dataset, **options)
      source_ptr = GDAL._pointer(GDAL::Dataset, source_dataset)
      destination_ptr = GDAL._pointer(GDAL::Dataset, destination_dataset, false)
      options_ptr = GDAL::Options.pointer(options)

      transformer_ptr = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer2(
        source_ptr,
        destination_ptr,
        options_ptr)

      ObjectSpace.define_finalizer(transformer_ptr) do
        destroy_gen_img_proj_transformer(transformer_ptr)
      end

      transformer_ptr
    end

    # @param source_wkt [String]
    # @param source_geo_transform [GDAL::GeoTransform, FFI::Pointer]
    # @param destination_wkt [String]
    # @param destination_geo_transform [GDAL::GeoTransform, FFI::Pointer]
    # @return [FFI::Pointer]
    def self.create_gen_img_proj_transformer3(source_wkt, source_geo_transform, destination_wkt, destination_geo_transform)
      source_ptr = GDAL._pointer(GDAL::GeoTransform, source_geo_transform)
      destination_ptr = GDAL._pointer(GDAL::GeoTransform, destination_geo_transform)

      transformer_ptr = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer3(
        source_wkt,
        source_ptr,
        destination_wkt,
        destination_ptr)

      ObjectSpace.define_finalizer(transformer_ptr) do
        destroy_gen_img_proj_transformer(transformer_ptr)
      end

      transformer_ptr
    end

    # @param transform_argument [FFI::Pointer]
    def self.destroy_gen_img_proj_transformer(transform_argument)
      FFI::GDAL::Alg.GDALDestroyGenImgProjTransformer(transform_argument)
    end

    def self.gen_img_proj_transform(transformer_arg_ptr, point_count, dest_to_src = false)
      transform_func(:GDALGenImgProjTransform, transformer_arg_ptr, point_count, dest_to_src)
    end

    # @return [FFI::Pointer] The pointer to use with #reprojection_transform.
    def self.create_reprojection_transformer(source_wkt, destination_wkt)
      transformer_ptr = FFI::GDAL::Alg.GDALCreateReprojectionTransformer(source_wkt, destination_wkt)

      ObjectSpace.define_finalizer(transformer_ptr) do
        destroy_reprojection_transformer(transformer_ptr)
      end

      transformer_ptr
    end

    # @param transform_argument [FFI::Pointer]
    def self.destroy_reprojection_transformer(transform_argument)
      FFI::GDAL::Alg.GDALDestroyReprojectionTransformer(transform_argument)
    end

    def self.reprojection_transform(transform_arg_ptr, point_count, dest_to_src = false)
      transform_func(:GDALReprojectionTransform, transform_arg_ptr, point_count, dest_to_src)
    end

    def self.transform_func(function, transform_arg_ptr, point_count, dest_to_src = false)
      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)
      success_ptr = FFI::MemoryPointer.new(:int)

puts "point count: #{point_count}"
puts "point count: #{dest_to_src}"
      result = FFI::GDAL::Alg.send(function,
        transform_arg_ptr,
        dest_to_src,
        point_count,
        x_ptr,
        y_ptr,
        z_ptr,
        success_ptr)

      puts "result: #{result}"
      puts "success: #{success_ptr.read_int.to_bool}"
      { x: x_ptr.read_double, y: y_ptr.read_double, z: z_ptr.read_double }
    end

    # @param rpc_info [GDAL::RPCInfo]
    # @param reversed [Boolean]
    # @param pixel_error_threshold [Float]
    # @param options [Hash]
    # @option options [Number] rpc_height A fixed hight offset to be applied to
    #   all points passed in.
    # @option options [Number] rpc_height_scale A factor used to multiply
    #   heights above ground.  Useful when elevation offsets of the DEM are not
    #   expressed in meters.
    # @option options [Number] rpc_dem Name of a GDAL dataset used to extract
    #   elevation offsets from.  This should be used in replacement of
    #   +rpc_height+.
    # @option options [Number] rpc_deminterpolation +near+, +bilinear+, or
    #   +cubic+.
    # @option options [Number] rpc_dem_missing_value Value of DEM height that
    #   must be unsed in case the DEM has a nodata value at the sampling point,
    #   or if its extent doesn't cover the requested coordinate.
    # @return [FFI::Pointer] Pointer to the transformer callback data.
    def self.create_rpc_transformer(rpc_info, pixel_error_threshold, reversed = false, **options)
      options_ptr = GDAL::Options.pointer(options)

      callback_dat_ptr = FFI::GDAL::Alg.GDALCreateRPCTransformer(
        rpc_info,
        reversed,
        pixel_error_threshold,
        options_ptr)
    end

    # @param gcp_list [Array<FFI::GDAL::GCP>]
    # @param reversed [Boolean]
    # @return [FFI::Pointer, nil] Pointer to the transform argument or +nil+ if
    #   creation fails.
    def self.create_tps_transformer(gcp_list, reversed = false)
      gcp_list_ptr = FFI::MemoryPointer.new(:pointer, gcp_list.size)

      gcp_list.each_with_index do |gcp, i|
        gcp_list_ptr[i].put_pointer(0, gcp.to_ptr)
      end

      transform_arg_ptr = FFI::GDAL::Alg.GDALCreateTPSTransformer(gcp_list.size, gcp_list_ptr, reversed)

      ObjectSpace.define_finalizer(transform_arg_ptr) do
        destroy_tps_transformer(transform_arg_ptr)
      end

      transform_arg_ptr
    end

    # @param transform_argument [FFI::Pointer]
    def self.destroy_tps_transformer(transform_argument)
      FFI::GDAL::Alg.GDALDestroyTPSTransformer(transform_argument)
    end
  end
end
