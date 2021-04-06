module Natour
  module StdoutUtils
    module_function

    def suppress_output
      orig_stdout = $stdout.clone
      orig_stderr = $stderr.clone
      $stdout.reopen(File.new(File::NULL, 'w'))
      $stderr.reopen(File.new(File::NULL, 'w'))
      yield
    ensure
      $stdout.reopen(orig_stdout)
      $stderr.reopen(orig_stderr)
    end
  end
end
