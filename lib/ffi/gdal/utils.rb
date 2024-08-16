# frozen_string_literal: true

require "ffi"
require_relative "../../ext/ffi_library_function_checks"

module FFI
  module GDAL
    module Utils
      extend FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------

      ##############################################
      ### Common arguments for utility functions ###
      ##############################################

      # GDALDatasetH -- the dataset handle (typical result of GDAL Utils).
      typedef FFI::GDAL::GDAL.find_type(:GDALDatasetH), :GDALDatasetH

      # papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      # The accepted options are the ones of the according gdal* utility.
      typedef :pointer, :papszArgv

      # psOptionsForBinary -- (output) may be NULL (and should generally be NULL).
      # NOTE: We don't use it in the Ruby-fied API. Keeping for documentation purposes.
      typedef :pointer, :psOptionsForBinary

      # pszDest -- the destination dataset path.
      typedef :string, :pszDest

      # hDataset -- the dataset handle.
      typedef :GDALDatasetH, :hDataset

      # hSrcDataset -- the source dataset handle
      typedef :GDALDatasetH, :hSrcDataset

      # hDstDS -- the destination dataset handle.
      typedef :GDALDatasetH, :hDstDS

      # nSrcCount -- the number of input datasets.
      typedef :int, :nSrcCount

      # pahSrcDS -- the list of input datasets.
      typedef :pointer, :pahSrcDS

      # pszProcessing -- the processing to apply
      # (one of "hillshade", "slope", "aspect", "color-relief", "TRI", "TPI", "Roughness")
      # NOTE: Only used by GDALDEMProcessing.
      typedef :string, :pszProcessing

      # pszColorFilename -- color file (mandatory for "color-relief" processing, should be NULL otherwise)
      # NOTE: Only used by GDALDEMProcessing.
      typedef :string, :pszColorFilename

      # pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      typedef :pointer, :pbUsageError

      ########################################
      ### Pointers to GDAL Options Structs ###
      ########################################

      # https://gdal.org/api/gdal_utils.html#_CPPv415GDALInfoOptions
      typedef :pointer, :GDALInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv420GDALTranslateOptions
      typedef :pointer, :GDALTranslateOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv418GDALWarpAppOptions
      typedef :pointer, :GDALWarpAppOptions

      # # https://gdal.org/api/gdal_utils.html#_CPPv426GDALVectorTranslateOptions
      typedef :pointer, :GDALVectorTranslateOptions

      # # https://gdal.org/api/gdal_utils.html#_CPPv424GDALDEMProcessingOptions
      typedef :pointer, :GDALDEMProcessingOptions

      # # https://gdal.org/api/gdal_utils.html#_CPPv420GDALNearblackOptions
      typedef :pointer, :GDALNearblackOptions

      # # https://gdal.org/api/gdal_utils.html#_CPPv415GDALGridOptions
      typedef :pointer, :GDALGridOptions

      # # https://gdal.org/api/gdal_utils.html#_CPPv420GDALRasterizeOptions
      typedef :pointer, :GDALRasterizeOptions

      # # https://gdal.org/api/gdal_utils.html#_CPPv420GDALFootprintOptions
      typedef :pointer, :GDALFootprintOptions

      # # https://gdal.org/api/gdal_utils.html#_CPPv419GDALBuildVRTOptions
      typedef :pointer, :GDALBuildVRTOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALMultiDimInfoOptions
      typedef :pointer, :GDALMultiDimInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv428GDALMultiDimTranslateOptions
      typedef :pointer, :GDALMultiDimTranslateOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv421GDALVectorInfoOptions
      typedef :pointer, :GDALVectorInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv420GDALTileIndexOptions
      typedef :pointer, :GDALTileIndexOptions

      # -----------------------------------------------------------------------
      # Functions
      # -----------------------------------------------------------------------

      ################
      ### GDALInfo ###
      ################

      # https://gdal.org/api/gdal_utils.html#_CPPv418GDALInfoOptionsNewPPcP24GDALInfoOptionsForBinary
      # GDALInfoOptions *GDALInfoOptionsNew(char **papszArgv, GDALInfoOptionsForBinary *psOptionsForBinary)
      #
      # Allocates a GDALInfoOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #    papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #      The accepted options are the ones of the gdalinfo utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdalinfo_bin.cpp
      #     use case) must be allocated with GDALInfoOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options, subdataset number...
      # Returns:
      #   pointer to the allocated GDALInfoOptions struct. Must be freed with GDALInfoOptionsFree().
      attach_function :GDALInfoOptionsNew, %i[papszArgv psOptionsForBinary], :GDALInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv419GDALInfoOptionsFreeP15GDALInfoOptions
      # void GDALInfoOptionsFree(GDALInfoOptions *psOptions)
      #
      # Frees the GDALInfoOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALInfo().
      attach_function :GDALInfoOptionsFree, [:GDALInfoOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv48GDALInfo12GDALDatasetHPK15GDALInfoOptions
      # char *GDALInfo(GDALDatasetH hDataset, const GDALInfoOptions *psOptions)
      #
      # Lists various information about a GDAL supported raster dataset.
      # This is the equivalent of the gdalinfo utility.
      # GDALInfoOptions* must be allocated and freed with GDALInfoOptionsNew() and GDALInfoOptionsFree() respectively.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   hDataset -- the dataset handle.
      #   psOptions -- the options structure returned by GDALInfoOptionsNew() or NULL.
      # Returns:
      #   string corresponding to the information about the raster dataset (must be freed with CPLFree()), or NULL
      #     in case of error.
      attach_function :GDALInfo,
                      %i[hDataset GDALInfoOptions],
                      :strptr

      #####################
      ### GDALTranslate ###
      #####################

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALTranslateOptionsNewPPcP29GDALTranslateOptionsForBinary
      # GDALTranslateOptions *GDALTranslateOptionsNew(
      #   char **papszArgv,
      #   GDALTranslateOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALTranslateOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdal_translate utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALTranslateOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALTranslateOptions struct. Must be freed with GDALTranslateOptionsFree().
      attach_function :GDALTranslateOptionsNew, %i[papszArgv psOptionsForBinary], :GDALTranslateOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv424GDALTranslateOptionsFreeP20GDALTranslateOptions
      # void GDALTranslateOptionsFree(GDALTranslateOptions *psOptions)
      #
      # Frees the GDALTranslateOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALTranslate().
      attach_function :GDALTranslateOptionsFree, [:GDALTranslateOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv413GDALTranslatePKc12GDALDatasetHPK20GDALTranslateOptionsPi
      # GDALDatasetH GDALTranslate(
      #   const char *pszDestFilename,
      #   GDALDatasetH hSrcDataset,
      #   const GDALTranslateOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Converts raster data between different formats.
      # This is the equivalent of the gdal_translate utility.
      # GDALTranslateOptions* must be allocated and freed with GDALTranslateOptionsNew() and
      # GDALTranslateOptionsFree() respectively.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path.
      #   hSrcDataset -- the source dataset handle.
      #   psOptionsIn -- the options struct returned by GDALTranslateOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose()) or NULL in case of error.
      #     If the output format is a VRT dataset, then the returned VRT dataset has a reference to hSrcDataset.
      #     Hence hSrcDataset should be closed after the returned dataset if using GDALClose().
      #     A safer alternative is to use GDALReleaseDataset() instead of using GDALClose(),
      #     in which case you can close datasets in any order.
      attach_function :GDALTranslate,
                      %i[pszDest hSrcDataset GDALTranslateOptions pbUsageError],
                      :GDALDatasetH

      ################
      ### GDALWarp ###
      ################

      # https://gdal.org/api/gdal_utils.html#_CPPv421GDALWarpAppOptionsNewPPcP27GDALWarpAppOptionsForBinary
      # GDALWarpAppOptions *GDALWarpAppOptionsNew(char **papszArgv, GDALWarpAppOptionsForBinary *psOptionsForBinary)
      #
      # Allocates a GDALWarpAppOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdalwarp utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALWarpAppOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALWarpAppOptions struct. Must be freed with GDALWarpAppOptionsFree().
      attach_function :GDALWarpAppOptionsNew, %i[papszArgv psOptionsForBinary], :GDALWarpAppOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv422GDALWarpAppOptionsFreeP18GDALWarpAppOptions
      # void GDALWarpAppOptionsFree(GDALWarpAppOptions *psOptions)
      #
      # Frees the GDALWarpAppOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALWarp().
      attach_function :GDALWarpAppOptionsFree, [:GDALWarpAppOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv48GDALWarpPKc12GDALDatasetHiP12GDALDatasetHPK18GDALWarpAppOptionsPi
      # GDALDatasetH GDALWarp(
      #   const char *pszDest,
      #   GDALDatasetH hDstDS,
      #   int nSrcCount,
      #   GDALDatasetH *pahSrcDS,
      #   const GDALWarpAppOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Image reprojection and warping function.
      # This is the equivalent of the gdalwarp utility.
      # GDALWarpAppOptions* must be allocated and freed with GDALWarpAppOptionsNew() and
      # GDALWarpAppOptionsFree() respectively. pszDest and hDstDS cannot be used at the same time.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path or NULL.
      #   hDstDS -- the destination dataset or NULL.
      #   nSrcCount -- the number of input datasets.
      #   pahSrcDS -- the list of input datasets. For practical purposes, the type of this argument should be
      #     considered as "const GDALDatasetH* const*", that is neither the array nor its values are mutated by
      #     this function.
      #   psOptionsIn -- the options struct returned by GDALWarpAppOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred, or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose(), or hDstDS if not NULL) or NULL
      #     in case of error. If the output format is a VRT dataset, then the returned VRT dataset has
      #     a reference to pahSrcDS[0]. Hence pahSrcDS[0] should be closed after the returned dataset if
      #     using GDALClose(). A safer alternative is to use GDALReleaseDataset() instead of using GDALClose(), in
      #     which case you can close datasets in any order.
      attach_function :GDALWarp,
                      %i[pszDest hDstDS nSrcCount pahSrcDS GDALWarpAppOptions pbUsageError],
                      :GDALDatasetH

      ###########################
      ### GDALVectorTranslate ###
      ###########################

      # https://gdal.org/api/gdal_utils.html#_CPPv429GDALVectorTranslateOptionsNewPPcP35GDALVectorTranslateOptionsForBinary
      # GDALVectorTranslateOptions *GDALVectorTranslateOptionsNew(
      #   char **papszArgv,
      #   GDALVectorTranslateOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALVectorTranslateOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the ogr2ogr utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALVectorTranslateOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALVectorTranslateOptions struct. Must be freed with
      #     GDALVectorTranslateOptionsFree().
      attach_function :GDALVectorTranslateOptionsNew, %i[papszArgv psOptionsForBinary], :GDALVectorTranslateOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv430GDALVectorTranslateOptionsFreeP26GDALVectorTranslateOptions
      # void GDALVectorTranslateOptionsFree(GDALVectorTranslateOptions *psOptions)
      #
      # Frees the GDALVectorTranslateOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALVectorTranslate().
      attach_function :GDALVectorTranslateOptionsFree, [:GDALVectorTranslateOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv419GDALVectorTranslatePKc12GDALDatasetHiP12GDALDatasetHPK26GDALVectorTranslateOptionsPi
      # GDALDatasetH GDALVectorTranslate(
      #   const char *pszDest,
      #   GDALDatasetH hDstDS,
      #   int nSrcCount,
      #   GDALDatasetH *pahSrcDS,
      #   const GDALVectorTranslateOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Converts vector data between file formats.
      # This is the equivalent of the ogr2ogr utility.
      # GDALVectorTranslateOptions* must be allocated and freed with GDALVectorTranslateOptionsNew() and
      # GDALVectorTranslateOptionsFree() respectively. pszDest and hDstDS cannot be used at the same time.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path or NULL.
      #   hDstDS -- the destination dataset or NULL.
      #   nSrcCount -- the number of input datasets (only 1 supported currently)
      #   pahSrcDS -- the list of input datasets.
      #   psOptionsIn -- the options struct returned by GDALVectorTranslateOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred, or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose(), or hDstDS is not NULL) or NULL
      #     in case of error.
      attach_function :GDALVectorTranslate,
                      %i[pszDest hDstDS nSrcCount pahSrcDS GDALVectorTranslateOptions pbUsageError],
                      :GDALDatasetH

      #########################
      ### GDALDEMProcessing ###
      #########################

      # https://gdal.org/api/gdal_utils.html#_CPPv427GDALDEMProcessingOptionsNewPPcP33GDALDEMProcessingOptionsForBinary
      # GDALDEMProcessingOptions *GDALDEMProcessingOptionsNew(
      #   char **papszArgv,
      #   GDALDEMProcessingOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALDEMProcessingOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdaldem utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALDEMProcessingOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALDEMProcessingOptions struct. Must be freed with GDALDEMProcessingOptionsFree().
      attach_function :GDALDEMProcessingOptionsNew, %i[papszArgv psOptionsForBinary], :GDALDEMProcessingOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv428GDALDEMProcessingOptionsFreeP24GDALDEMProcessingOptions
      # void GDALDEMProcessingOptionsFree(GDALDEMProcessingOptions *psOptions)
      #
      # Frees the GDALDEMProcessingOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALDEMProcessing().
      attach_function :GDALDEMProcessingOptionsFree, [:GDALDEMProcessingOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv417GDALDEMProcessingPKc12GDALDatasetHPKcPKcPK24GDALDEMProcessingOptionsPi
      # GDALDatasetH GDALDEMProcessing(
      #   const char *pszDestFilename,
      #   GDALDatasetH hSrcDataset,
      #   const char *pszProcessing,
      #   const char *pszColorFilename,
      #   const GDALDEMProcessingOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Apply a DEM processing.
      # This is the equivalent of the gdaldem utility.
      # GDALDEMProcessingOptions* must be allocated and freed with GDALDEMProcessingOptionsNew() and
      # GDALDEMProcessingOptionsFree() respectively.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path.
      #   hSrcDataset -- the source dataset handle.
      #   pszProcessing -- the processing to apply (one of "hillshade", "slope", "aspect", "color-relief", "TRI",
      #     "TPI", "Roughness")
      #   pszColorFilename -- color file (mandatory for "color-relief" processing, should be NULL otherwise)
      #   psOptionsIn -- the options struct returned by GDALDEMProcessingOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose()) or NULL in case of error.
      attach_function :GDALDEMProcessing,
                      %i[pszDest hSrcDataset pszProcessing pszColorFilename GDALDEMProcessingOptions pbUsageError],
                      :GDALDatasetH

      #####################
      ### GDALNearblack ###
      #####################

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALNearblackOptionsNewPPcP29GDALNearblackOptionsForBinary
      # GDALNearblackOptions *GDALNearblackOptionsNew(
      #   char **papszArgv,
      #   GDALNearblackOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALNearblackOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the nearblack utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALNearblackOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALNearblackOptions struct. Must be freed with GDALNearblackOptionsFree().
      attach_function :GDALNearblackOptionsNew, %i[papszArgv psOptionsForBinary], :GDALNearblackOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv424GDALNearblackOptionsFreeP20GDALNearblackOptions
      # void GDALNearblackOptionsFree(GDALNearblackOptions *psOptions)
      #
      # Frees the GDALNearblackOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALNearblack().
      attach_function :GDALNearblackOptionsFree, [:GDALNearblackOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv413GDALNearblackPKc12GDALDatasetH12GDALDatasetHPK20GDALNearblackOptionsPi
      # GDALDatasetH GDALNearblack(
      #   const char *pszDest,
      #   GDALDatasetH hDstDS,
      #   GDALDatasetH hSrcDS,
      #   const GDALNearblackOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Convert nearly black/white borders to exact value.
      # This is the equivalent of the nearblack utility.
      # GDALNearblackOptions* must be allocated and freed with GDALNearblackOptionsNew()
      # and GDALNearblackOptionsFree() respectively. pszDest and hDstDS cannot be used at the same time.
      # In-place update (i.e. hDstDS == hSrcDataset) is possible for formats that support it,
      # and if the dataset is opened in update mode.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path or NULL.
      #   hDstDS -- the destination dataset or NULL. Might be equal to hSrcDataset.
      #   hSrcDataset -- the source dataset handle.
      #   psOptionsIn -- the options struct returned by GDALNearblackOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose(), or hDstDS when it is not NULL) or NULL
      #     in case of error.
      attach_function :GDALNearblack,
                      %i[pszDest hDstDS hSrcDataset GDALNearblackOptions pbUsageError],
                      :GDALDatasetH

      ################
      ### GDALGrid ###
      ################

      # https://gdal.org/api/gdal_utils.html#_CPPv418GDALGridOptionsNewPPcP24GDALGridOptionsForBinary
      # GDALGridOptions *GDALGridOptionsNew(char **papszArgv, GDALGridOptionsForBinary *psOptionsForBinary)
      #
      # Allocates a GDALGridOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdal_translate utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALGridOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALGridOptions struct. Must be freed with GDALGridOptionsFree().
      attach_function :GDALGridOptionsNew, %i[papszArgv psOptionsForBinary], :GDALGridOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv419GDALGridOptionsFreeP15GDALGridOptions
      # void GDALGridOptionsFree(GDALGridOptions *psOptions)
      #
      # Frees the GDALGridOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALGrid().
      attach_function :GDALGridOptionsFree, [:GDALGridOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv48GDALGridPKc12GDALDatasetHPK15GDALGridOptionsPi
      # GDALDatasetH GDALGrid(
      #   const char *pszDest,
      #   GDALDatasetH hSrcDS,
      #   const GDALGridOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Create raster from the scattered data.
      # This is the equivalent of the gdal_grid utility.
      # GDALGridOptions* must be allocated and freed with GDALGridOptionsNew() and GDALGridOptionsFree() respectively.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path.
      #   hSrcDataset -- the source dataset handle.
      #   psOptionsIn -- the options struct returned by GDALGridOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose()) or NULL in case of error.
      attach_function :GDALGrid,
                      %i[pszDest hSrcDataset GDALGridOptions pbUsageError],
                      :GDALDatasetH

      #####################
      ### GDALRasterize ###
      #####################

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALRasterizeOptionsNewPPcP29GDALRasterizeOptionsForBinary
      # GDALRasterizeOptions *GDALRasterizeOptionsNew(
      #   char **papszArgv,
      #   GDALRasterizeOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALRasterizeOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdal_rasterize utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALRasterizeOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALRasterizeOptions struct. Must be freed with GDALRasterizeOptionsFree().
      attach_function :GDALRasterizeOptionsNew, %i[papszArgv psOptionsForBinary], :GDALRasterizeOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv424GDALRasterizeOptionsFreeP20GDALRasterizeOptions
      # void GDALRasterizeOptionsFree(GDALRasterizeOptions *psOptions)
      #
      # Frees the GDALRasterizeOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALRasterize().
      attach_function :GDALRasterizeOptionsFree, [:GDALRasterizeOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv413GDALRasterizePKc12GDALDatasetH12GDALDatasetHPK20GDALRasterizeOptionsPi
      # GDALDatasetH GDALRasterize(
      #   const char *pszDest,
      #   GDALDatasetH hDstDS,
      #   GDALDatasetH hSrcDS,
      #   const GDALRasterizeOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Burns vector geometries into a raster.
      # This is the equivalent of the gdal_rasterize utility.
      # GDALRasterizeOptions* must be allocated and freed with GDALRasterizeOptionsNew() and
      # GDALRasterizeOptionsFree() respectively. pszDest and hDstDS cannot be used at the same time.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path or NULL.
      #   hDstDS -- the destination dataset or NULL.
      #   hSrcDataset -- the source dataset handle.
      #   psOptionsIn -- the options struct returned by GDALRasterizeOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose(), or hDstDS is not NULL) or NULL
      #     in case of error.
      attach_function :GDALRasterize,
                      %i[pszDest hDstDS hSrcDataset GDALRasterizeOptions pbUsageError],
                      :GDALDatasetH

      #####################
      ### GDALFootprint ###
      #####################

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALFootprintOptionsNewPPcP29GDALFootprintOptionsForBinary
      # GDALFootprintOptions *GDALFootprintOptionsNew(
      #   char **papszArgv,
      #   GDALFootprintOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALFootprintOptions struct.
      #
      # Since
      #   GDAL 3.8
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdal_rasterize utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdal_translate_bin.cpp
      #     use case) must be allocated with GDALFootprintOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALFootprintOptions struct. Must be freed with GDALFootprintOptionsFree().
      attach_function :GDALFootprintOptionsNew, %i[papszArgv psOptionsForBinary], :GDALFootprintOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv424GDALFootprintOptionsFreeP20GDALFootprintOptions
      # void GDALFootprintOptionsFree(GDALFootprintOptions *psOptions)
      #
      # Frees the GDALFootprintOptions struct.
      #
      # Since
      #   GDAL 3.8
      # Parameters:
      #   psOptions -- the options struct for GDALFootprint().
      attach_function :GDALFootprintOptionsFree, [:GDALFootprintOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv413GDALFootprintPKc12GDALDatasetH12GDALDatasetHPK20GDALFootprintOptionsPi
      # GDALDatasetH GDALFootprint(
      #   const char *pszDest,
      #   GDALDatasetH hDstDS,
      #   GDALDatasetH hSrcDS,
      #   const GDALFootprintOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Computes the footprint of a raster.
      # This is the equivalent of the gdal_footprint utility.
      # GDALFootprintOptions* must be allocated and freed with GDALFootprintOptionsNew() and
      # GDALFootprintOptionsFree() respectively. pszDest and hDstDS cannot be used at the same time.
      #
      # Since
      #   GDAL 3.8
      # Parameters:
      #   pszDest -- the vector destination dataset path or NULL.
      #   hDstDS -- the vector destination dataset or NULL.
      #   hSrcDataset -- the raster source dataset handle.
      #   psOptionsIn -- the options struct returned by GDALFootprintOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose(), or hDstDS is not NULL) or NULL
      #     in case of error.
      attach_function :GDALFootprint,
                      %i[pszDest hDstDS hSrcDataset GDALFootprintOptions pbUsageError],
                      :GDALDatasetH

      ####################
      ### GDALBuildVRT ###
      ####################

      # https://gdal.org/api/gdal_utils.html#_CPPv422GDALBuildVRTOptionsNewPPcP28GDALBuildVRTOptionsForBinary
      # GDALBuildVRTOptions *GDALBuildVRTOptionsNew(char **papszArgv, GDALBuildVRTOptionsForBinary *psOptionsForBinary)
      #
      # Allocates a GDALBuildVRTOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdalbuildvrt utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdalbuildvrt_bin.cpp
      #     use case) must be allocated with GDALBuildVRTOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALBuildVRTOptions struct. Must be freed with GDALBuildVRTOptionsFree().
      attach_function :GDALBuildVRTOptionsNew, %i[papszArgv psOptionsForBinary], :GDALBuildVRTOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALBuildVRTOptionsFreeP19GDALBuildVRTOptions
      # void GDALBuildVRTOptionsFree(GDALBuildVRTOptions *psOptions)
      #
      # Frees the GDALBuildVRTOptions struct.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   psOptions -- the options struct for GDALBuildVRT().
      attach_function :GDALBuildVRTOptionsFree, [:GDALBuildVRTOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv412GDALBuildVRTPKciP12GDALDatasetHPPCKcPK19GDALBuildVRTOptionsPi
      # GDALDatasetH GDALBuildVRT(
      #   const char *pszDest,
      #   int nSrcCount,
      #   GDALDatasetH *pahSrcDS,
      #   const char *const *papszSrcDSNames,
      #   const GDALBuildVRTOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Build a VRT from a list of datasets.
      # This is the equivalent of the gdalbuildvrt utility.
      # GDALBuildVRTOptions* must be allocated and freed with GDALBuildVRTOptionsNew()
      # and GDALBuildVRTOptionsFree() respectively. pahSrcDS and papszSrcDSNames cannot be used at the same time.
      #
      # Since
      #   GDAL 2.1
      # Parameters:
      #   pszDest -- the destination dataset path.
      #   nSrcCount -- the number of input datasets.
      #   pahSrcDS -- the list of input datasets (or NULL, exclusive with papszSrcDSNames).
      #     For practical purposes, the type of this argument should be considered as "const GDALDatasetH* const*",
      #     that is neither the array nor its values are mutated by this function.
      #   papszSrcDSNames -- the list of input dataset names (or NULL, exclusive with pahSrcDS)
      #   psOptionsIn -- the options struct returned by GDALBuildVRTOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose()) or NULL in case of error.
      #     If using pahSrcDS, the returned VRT dataset has a reference to each pahSrcDS[] element.
      #     Hence pahSrcDS[] elements should be closed after the returned dataset if using GDALClose().
      #     A safer alternative is to use GDALReleaseDataset() instead of using GDALClose(), in which case
      #     you can close datasets in any order.
      attach_function :GDALBuildVRT,
                      %i[pszDest nSrcCount pahSrcDS pointer GDALBuildVRTOptions pbUsageError],
                      :GDALDatasetH

      ########################
      ### GDALMultiDimInfo ###
      ########################

      # https://gdal.org/api/gdal_utils.html#_CPPv426GDALMultiDimInfoOptionsNewPPcP32GDALMultiDimInfoOptionsForBinary
      # GDALMultiDimInfoOptions *GDALMultiDimInfoOptionsNew(
      #   char **papszArgv,
      #   GDALMultiDimInfoOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALMultiDimInfoOptions struct.
      #
      # Since
      #   GDAL 3.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdalmdiminfo utility.
      #   psOptionsForBinary -- should be nullptr, unless called from gdalmultidiminfo_bin.cpp
      # Returns:
      #   pointer to the allocated GDALMultiDimInfoOptions struct. Must be freed with GDALMultiDimInfoOptionsFree().
      attach_function :GDALMultiDimInfoOptionsNew, %i[papszArgv psOptionsForBinary], :GDALMultiDimInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv427GDALMultiDimInfoOptionsFreeP23GDALMultiDimInfoOptions
      # void GDALMultiDimInfoOptionsFree(GDALMultiDimInfoOptions *psOptions)
      #
      # Frees the GDALMultiDimInfoOptions struct.
      #
      # Since
      #   GDAL 3.1
      # Parameters:
      #   psOptions -- the options struct for GDALMultiDimInfo().
      attach_function :GDALMultiDimInfoOptionsFree, [:GDALMultiDimInfoOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv416GDALMultiDimInfo12GDALDatasetHPK23GDALMultiDimInfoOptions
      # char *GDALMultiDimInfo(GDALDatasetH hDataset, const GDALMultiDimInfoOptions *psOptions)
      #
      # Lists various information about a GDAL multidimensional dataset.
      # This is the equivalent of the gdalmdiminfoutility.
      # GDALMultiDimInfoOptions* must be allocated and freed with GDALMultiDimInfoOptionsNew() and
      # GDALMultiDimInfoOptionsFree() respectively.
      #
      # Since
      #   GDAL 3.1
      # Parameters:
      #   hDataset -- the dataset handle.
      #   psOptionsIn -- the options structure returned by GDALMultiDimInfoOptionsNew() or NULL.
      # Returns:
      #   string corresponding to the information about the raster dataset (must be freed with CPLFree()), or NULL
      #     in case of error.
      attach_function :GDALMultiDimInfo,
                      %i[hDataset GDALMultiDimInfoOptions],
                      :strptr

      #############################
      ### GDALMultiDimTranslate ###
      #############################

      # https://gdal.org/api/gdal_utils.html#_CPPv431GDALMultiDimTranslateOptionsNewPPcP37GDALMultiDimTranslateOptionsForBinary
      # GDALMultiDimTranslateOptions *GDALMultiDimTranslateOptionsNew(
      #   char **papszArgv,
      #   GDALMultiDimTranslateOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALMultiDimTranslateOptions struct.
      #
      # Since
      #   GDAL 3.1
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdalmdimtranslate utility.
      #   psOptionsForBinary -- should be nullptr, unless called from gdalmdimtranslate_bin.cpp
      # Returns:
      #   pointer to the allocated GDALMultiDimTranslateOptions struct. Must be freed with
      #     GDALMultiDimTranslateOptionsFree().
      attach_function :GDALMultiDimTranslateOptionsNew, %i[papszArgv psOptionsForBinary], :GDALMultiDimTranslateOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv432GDALMultiDimTranslateOptionsFreeP28GDALMultiDimTranslateOptions
      # void GDALMultiDimTranslateOptionsFree(GDALMultiDimTranslateOptions *psOptions)
      #
      # Frees the GDALMultiDimTranslateOptions struct.
      #
      # Since
      #   GDAL 3.1
      # Parameters:
      #   psOptions -- the options struct for GDALMultiDimTranslate().
      attach_function :GDALMultiDimTranslateOptionsFree, [:GDALMultiDimTranslateOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv421GDALMultiDimTranslatePKc12GDALDatasetHiP12GDALDatasetHPK28GDALMultiDimTranslateOptionsPi
      # GDALDatasetH GDALMultiDimTranslate(
      #   const char *pszDest,
      #   GDALDatasetH hDstDataset,
      #   int nSrcCount,
      #   GDALDatasetH *pahSrcDS,
      #   const GDALMultiDimTranslateOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Converts raster data between different formats.
      # This is the equivalent of the gdalmdimtranslate utility.
      # GDALMultiDimTranslateOptions* must be allocated and freed with GDALMultiDimTranslateOptionsNew()
      # and GDALMultiDimTranslateOptionsFree() respectively. pszDest and hDstDS cannot be used at the same time.
      #
      # Since
      #   GDAL 3.1
      # Parameters:
      #   pszDest -- the destination dataset path or NULL.
      #   hDstDS -- the destination dataset or NULL.
      #   nSrcCount -- the number of input datasets.
      #   pahSrcDS -- the list of input datasets.
      #   psOptions -- the options struct returned by GDALMultiDimTranslateOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred or NULL.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose(), or hDstDS is not NULL) or NULL
      #     in case of error.
      attach_function :GDALMultiDimTranslate,
                      %i[pszDest hDstDS nSrcCount pahSrcDS GDALMultiDimTranslateOptions pbUsageError],
                      :GDALDatasetH

      ######################
      ### GDALVectorInfo ###
      ######################

      # https://gdal.org/api/gdal_utils.html#_CPPv424GDALVectorInfoOptionsNewPPcP30GDALVectorInfoOptionsForBinary
      # GDALVectorInfoOptions *GDALVectorInfoOptionsNew(
      #   char **papszArgv,
      #   GDALVectorInfoOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALVectorInfoOptions struct.
      #
      # Since
      #   GDAL 3.7
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the ogrinfo utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (ogrinfo_bin.cpp
      #     use case) must be allocated with GDALVectorInfoOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options, subdataset number...
      # Returns:
      #   pointer to the allocated GDALVectorInfoOptions struct. Must be freed with GDALVectorInfoOptionsFree().
      attach_function :GDALVectorInfoOptionsNew, %i[papszArgv psOptionsForBinary], :GDALVectorInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv425GDALVectorInfoOptionsFreeP21GDALVectorInfoOptions
      # void GDALVectorInfoOptionsFree(GDALVectorInfoOptions *psOptions)
      #
      # Frees the GDALVectorInfoOptions struct.
      #
      # Since
      #   GDAL 3.7
      # Parameters:
      #   psOptions -- the options struct for GDALVectorInfo().
      attach_function :GDALVectorInfoOptionsFree, [:GDALVectorInfoOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv414GDALVectorInfo12GDALDatasetHPK21GDALVectorInfoOptions
      # char *GDALVectorInfo(GDALDatasetH hDataset, const GDALVectorInfoOptions *psOptions)
      #
      # Lists various information about a GDAL supported vector dataset.
      # This is the equivalent of the ogrinfo utility.
      # GDALVectorInfoOptions* must be allocated and freed with GDALVectorInfoOptionsNew()
      # and GDALVectorInfoOptionsFree() respectively.
      #
      # Since
      #   GDAL 3.7
      # Parameters:
      #   hDataset -- the dataset handle.
      #   psOptions -- the options structure returned by GDALVectorInfoOptionsNew() or NULL.
      # Returns:
      #   string corresponding to the information about the raster dataset (must be freed with CPLFree()), or NULL
      #     in case of error.
      attach_function :GDALVectorInfo,
                      %i[hDataset GDALVectorInfoOptions],
                      :strptr

      #####################
      ### GDALTileIndex ###
      #####################

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALTileIndexOptionsNewPPcP29GDALTileIndexOptionsForBinary
      # GDALTileIndexOptions *GDALTileIndexOptionsNew(
      #   char **papszArgv,
      #   GDALTileIndexOptionsForBinary *psOptionsForBinary
      # )
      #
      # Allocates a GDALTileIndexOptions struct.
      #
      # Since
      #   GDAL 3.9
      # Parameters:
      #   papszArgv -- NULL terminated list of options (potentially including filename and open options too), or NULL.
      #     The accepted options are the ones of the gdaltindex utility.
      #   psOptionsForBinary -- (output) may be NULL (and should generally be NULL), otherwise (gdaltindex_bin.cpp
      #     use case) must be allocated with GDALTileIndexOptionsForBinaryNew() prior to this function.
      #     Will be filled with potentially present filename, open options,...
      # Returns:
      #   pointer to the allocated GDALTileIndexOptions struct. Must be freed with GDALTileIndexOptionsFree().
      attach_function :GDALTileIndexOptionsNew, %i[papszArgv psOptionsForBinary], :GDALTileIndexOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv424GDALTileIndexOptionsFreeP20GDALTileIndexOptions
      # void GDALTileIndexOptionsFree(GDALTileIndexOptions *psOptions)
      #
      # Frees the GDALTileIndexOptions struct.
      #
      # Since
      #   GDAL 3.9
      # Parameters:
      #   psOptions -- the options struct for GDALTileIndex().
      attach_function :GDALTileIndexOptionsFree, [:GDALTileIndexOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv413GDALTileIndexPKciPPCKcPK20GDALTileIndexOptionsPi
      # GDALDatasetH GDALTileIndex(
      #   const char *pszDest,
      #   int nSrcCount,
      #   const char *const *papszSrcDSNames,
      #   const GDALTileIndexOptions *psOptions,
      #   int *pbUsageError
      # )
      #
      # Build a tile index from a list of datasets.
      # This is the equivalent of the gdaltindex utility.
      # GDALTileIndexOptions* must be allocated and freed with GDALTileIndexOptionsNew()
      # and GDALTileIndexOptionsFree() respectively.
      #
      # Since
      #   GDAL 3.9
      # Parameters:
      #   pszDest -- the destination dataset path.
      #   nSrcCount -- the number of input datasets.
      #   papszSrcDSNames -- the list of input dataset names
      #   psOptionsIn -- the options struct returned by GDALTileIndexOptionsNew() or NULL.
      #   pbUsageError -- pointer to a integer output variable to store if any usage error has occurred.
      # Returns:
      #   the output dataset (new dataset that must be closed using GDALClose()) or NULL in case of error.
      attach_function :GDALTileIndex,
                      %i[pszDest nSrcCount pointer GDALTileIndexOptions pbUsageError],
                      :GDALDatasetH
    end
  end
end
