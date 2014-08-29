require_relative '../gdal/exceptions'


class ::Symbol
  def to_ruby(none: true, debug: true, warning: false, failure: nil, fatal: nil, &block)
    case self
    when :none
      block_given? ? block.call : none
    when :debug
      block_given? ? block.call : debug
    when :warning then warning
    when :failure
      failure.nil? ? (raise CPLErrFailure) : failure
    when :fatal
      fatal.nil? ? (raise CPLErrFailure) : fatal
    end
  end
end
