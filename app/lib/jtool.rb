require 'open3'
# wrapper class around using the jtool command line utility
# http://newosxbook.com/tools/jtool.html
# Assumes running in a Linux environment for utilities
class Jtool

  attr_writer :jtool_exec, :timeout_exec

  class InvalidArch < RuntimeError; end

  def jtool_exec
    @jtool_exec || 'jtool' # should be in PATH
  end

  def timeout_exec
    @timeout_exec || 'timeout'
  end

  def run_command(*args)
    # all binaries are using arm64 and above
    stdout, stderr, status = Open3.capture3("#{timeout_exec} 30s #{jtool_exec} -arch arm64 #{args.join(' ')}")
    validate_arch!(stderr)
    stdout
  end

  def validate_arch!(stderr)
    raise InvalidArch if stderr.include?('Requested architecture not found in file')
  end

  def objc_classes(filepath)
    run_command('-d', 'objc', filepath).scrub('*').split(/\n/).reject { |c| %r{^//}.match(c) }.uniq
  end

  def shared_libraries(filepath)
    run_command('-L', filepath).split(/\n/).map { |l| l.gsub(/^\t/, '') }
  end
end
