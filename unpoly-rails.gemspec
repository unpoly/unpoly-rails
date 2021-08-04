lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unpoly/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "unpoly-rails"
  spec.version       = Unpoly::Rails::VERSION
  spec.authors       = ["Henning Koch"]
  spec.email         = ["henning.koch@makandra.de"]
  spec.description   = 'Rails bindings for Unpoly, the unobtrusive JavaScript framework'
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/unpoly/unpoly-rails"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*.rb'] + Dir['assets/unpoly/*.{css,js}'] + %w[LICENSE README.md .yardopts]
  spec.executables   = []
  spec.test_files    = []
  spec.require_paths = %w[lib]

  spec.add_dependency 'railties',      '>= 3.2'
  spec.add_dependency 'actionpack',    '>= 3.2'
  spec.add_dependency 'activesupport', '>= 3.2'
  spec.add_dependency 'memoized'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  # We use Module#prepend (2.1)
  # We use the safe navigation operator (2.3)
  spec.required_ruby_version = '>= 2.3.0'
end