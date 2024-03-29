require 'pathname'
require_relative 'lib/natour/version'

Gem::Specification.new do |spec|
  spec.name        = 'natour'
  spec.version     = Natour::VERSION
  spec.author      = 'Simon Gysi'
  spec.email       = 'simon.gysi@gmail.com'
  spec.summary     = "#{spec.name} provides an application and a library to document nature activities."
  spec.homepage    = 'https://github.com/simongysi/natour'
  spec.license     = 'MIT'
  spec.metadata    = { 'bug_tracker_uri' => 'https://github.com/simongysi/natour/issues',
                       'changelog_uri' => 'https://github.com/simongysi/natour/blob/main/CHANGELOG.adoc',
                       'source_code_uri' => 'https://github.com/simongysi/natour' }
  spec.files       = ['.natour.yml', 'CHANGELOG.adoc', 'LICENSE', 'README.adoc'] +
                     Pathname.glob('lib/**/*').reject(&:directory?).map(&:to_s)
  spec.executables = Pathname.glob('bin/**/*').reject(&:directory?).map(&:basename).map(&:to_s)
  spec.required_ruby_version = '>= 2.6'
  spec.add_runtime_dependency('asciidoctor', '~> 2.0')
  spec.add_runtime_dependency('asciidoctor-pdf', '~> 2.3')
  spec.add_runtime_dependency('clamp', '~> 1.3')
  spec.add_runtime_dependency('concurrent-ruby', '~> 1.1')
  spec.add_runtime_dependency('deep_merge', '~> 1.2')
  spec.add_runtime_dependency('ferrum', '~> 0.9')
  spec.add_runtime_dependency('fit4ruby', '~> 3.9')
  spec.add_runtime_dependency('nokogiri', '~> 1.10')
  spec.add_runtime_dependency('ruby-duration', '~> 3.2')
  spec.add_runtime_dependency('ruby-vips', '~> 2.0')
  spec.add_runtime_dependency('timeliness', '~> 0.4')
  spec.add_runtime_dependency('webrick', '~> 1.7')
  spec.add_runtime_dependency('word_wrap', '~> 1.0')
  spec.add_development_dependency('rubocop', '= 1.25')
end
