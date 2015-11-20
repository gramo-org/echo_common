$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'echo_common'

def stub_stdout_constant
  begin_block = <<-BLOCK
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    origin_stdout = STDOUT
    STDOUT = StringIO.new
  BLOCK
  TOPLEVEL_BINDING.eval begin_block

  yield
  return_str = STDOUT.string

  ensure_block = <<-BLOCK
    STDOUT = origin_stdout
    $VERBOSE = original_verbosity
  BLOCK
  TOPLEVEL_BINDING.eval ensure_block

  return_str
end
