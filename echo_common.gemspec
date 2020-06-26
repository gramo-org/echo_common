# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'echo_common/version'

Gem::Specification.new do |spec|
  spec.name          = "echo_common"
  spec.version       = EchoCommon::VERSION
  spec.authors       = ["Thorbjørn Hermansen"]
  spec.email         = ["thhermansen@gmail.com"]

  spec.summary       = %q{Common code for Echo}
  spec.description   = %q{Common code for Echo}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hanami-model", "~> 0.6.1"
  spec.add_dependency "hanami-utils", ">= 0.8", "< 1.4"
  spec.add_dependency "jwt", "~> 2"
  spec.add_dependency "elasticsearch", ">= 5.0.3", "< 7.9.0"
  spec.add_dependency "typhoeus", ">= 1.1.2", "< 1.4.0"
  spec.add_dependency "database_cleaner", ">= 1.5.1", "< 1.9.0"
  spec.add_dependency "rack-test", ">= 0.6.3", "< 1.2.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
