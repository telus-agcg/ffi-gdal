# frozen_string_literal: true

require "timeout"
require "tmpdir"
require "fileutils"
require "ffi-gdal"
require "gdal"

# Regression guard for the GDAL >= 3.11 warp worker-thread deadlock.
#
# GDAL's multi-threaded warp (NUM_THREADS > 1) reports warnings from worker threads. A freshly
# created raster is all zeros with no NoData set, so warping it with "-dstnodata 0" makes GDAL
# treat every valid 0 as a clash and emit "Value 0 in the source dataset has been changed to
# 1 ... to avoid being treated as NoData" -- from a worker thread. If ffi-gdal's *global* error
# handler is a Ruby callback, that report must run on FFI's callback-dispatcher thread, which
# needs the GVL. The calling Ruby thread holds the GVL while blocked inside the warp waiting on
# its workers, the workers block waiting for the callback, and the process deadlocks. GDAL 3.10
# reported from the calling thread, so it never surfaced.
#
# The fix installs GDAL's native C handler as the global handler (see
# GDAL::CPLErrorHandler::NATIVE_DEFAULT_HANDLER) and pushes the Ruby handler onto the main
# thread's thread-local stack, so worker threads never call into Ruby.
#
# The warp runs in a spawned pristine child process, NOT a forked one. GDAL caches its warp
# worker-thread pool process-globally, and pool threads do not survive fork: after any earlier
# in-process multi-threaded warp, a forked child queues warp work for dead pool threads and
# hangs forever, making this spec fail whenever spec order put such a spec first. A fresh
# process also reproduces the guarded scenario exactly: loading the gem installs its error
# handlers just as production boot does, then the multi-threaded warp runs. A regression
# surfaces as a detectable timeout instead of hanging the whole suite.
RSpec.describe "GDAL warp worker-thread deadlock", type: :integration do
  let(:source_dir) { Dir.mktmpdir }
  let(:source_path) { File.join(source_dir, "all_zero_source.tif") }
  let(:child_log_path) { File.join(source_dir, "child_log.txt") }

  before { create_all_zero_source(source_path) }
  after { FileUtils.remove_entry(source_dir) }

  # An all-zero raster with no NoData: warping it with "-dstnodata 0" makes every pixel a
  # "valid 0" and triggers the worker-thread NoData warning that exposes the deadlock.
  def create_all_zero_source(path)
    dataset = GDAL::Driver.by_name("GTiff").create_dataset(path, 256, 256, band_count: 3, data_type: :GDT_Byte)
    dataset.projection = "EPSG:3857"

    geo_transform = GDAL::GeoTransform.new
    geo_transform.x_origin = -13_711_381.13
    geo_transform.pixel_width = 30.0
    geo_transform.y_origin = 5_583_672.44
    geo_transform.pixel_height = -30.0
    dataset.geo_transform = geo_transform

    dataset.close
  end

  def child_warp_script
    <<~RUBY
      require "ffi-gdal"
      require "gdal"
      require "tmpdir"

      Dir.mktmpdir do |dir|
        GDAL::Dataset.open(ARGV.fetch(0), "r") do |source|
          GDAL::Utils::Warp.perform(
            dst_dataset_path: File.join(dir, "out.tif"),
            src_datasets: [source],
            options: GDAL::Utils::Warp::Options.new(
              options: [
                "-multi", "-wo", "NUM_THREADS=2", "-dstnodata", "0",
                "-t_srs", "EPSG:4326", "-of", "GTiff"
              ]
            )
          ).close
        end
      end
    RUBY
  end

  # Timeout.timeout is safe here: it only interrupts the parent's waitpid2 on the hung child,
  # never library code mid-operation.
  def run_pristine_child(script:, timeout_seconds:)
    pid = Process.spawn(
      RbConfig.ruby, "-rbundler/setup", "-e", script, source_path,
      %i[out err] => child_log_path
    )
    Timeout.timeout(timeout_seconds) do
      _pid, status = Process.waitpid2(pid)
      { success: status.success?, outcome: status.inspect }
    end
  rescue Timeout::Error
    kill_and_reap(pid)
    { success: false, outcome: "timed out after #{timeout_seconds}s (deadlock?)" }
  end

  def kill_and_reap(pid)
    Process.kill("KILL", pid)
    Process.waitpid(pid)
  rescue Errno::ESRCH, Errno::ECHILD
    # The child exited right at the timeout boundary and is already gone/reaped.
  end

  def failure_diagnostics(result)
    <<~MESSAGE
      expected the multi-threaded warp child to succeed, but it did not:
        outcome: #{result.fetch(:outcome)}
        child output: #{File.read(child_log_path).strip.inspect}
    MESSAGE
  end

  it "materializes a multi-threaded warp without deadlocking" do
    # Child boot (ruby + bundler + ffi-gdal) plus the warp is subsecond locally, but CI load
    # can slow it by an order of magnitude. A real deadlock hangs forever and success returns
    # immediately, so a generous timeout still catches regressions without slowing green runs.
    result = run_pristine_child(script: child_warp_script, timeout_seconds: 15)

    expect(result.fetch(:success)).to be(true), -> { failure_diagnostics(result) }
  end

  it "kills a hung child and reports timeout diagnostics" do
    result = run_pristine_child(script: "sleep", timeout_seconds: 1)

    expect(result.fetch(:success)).to be(false)
    expect(failure_diagnostics(result)).to eq(<<~MESSAGE)
      expected the multi-threaded warp child to succeed, but it did not:
        outcome: timed out after 1s (deadlock?)
        child output: ""
    MESSAGE
  end
end
