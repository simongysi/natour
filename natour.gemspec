require 'pathname'

Gem::Specification.new do |spec|
  spec.name        = 'natour'
  spec.version     = '0.3.0'
  spec.author      = 'Simon Gysi'
  spec.email       = 'simon.gysi@gmail.com'
  spec.summary     = "#{spec.name} provides an application and a library for reports on nature activities"
  spec.homepage    = 'https://rubygems.org/gems/natour'
  spec.license     = 'MIT'
  spec.metadata    = { 'bug_tracker_uri' => 'https://github.com/simongysi/natour/issues',
                       'changelog_uri' => 'https://github.com/simongysi/natour/blob/main/CHANGELOG.adoc',
                       'source_code_uri' => 'https://github.com/simongysi/natour' }
  spec.files       = ['README.adoc', 'CHANGELOG.adoc', 'LICENSE'] +
                     Pathname.glob('lib/**/*').reject(&:directory?).map(&:to_s)
  spec.executables = Pathname.glob('bin/**/*').reject(&:directory?).map(&:basename).map(&:to_s)
  spec.required_ruby_version = '>= 2.5'
  spec.add_runtime_dependency('asciidoctor', '~> 2.0')
  spec.add_runtime_dependency('asciidoctor-pdf', '~> 1.5')
  spec.add_runtime_dependency('concurrent-ruby', '~> 1.1')
  spec.add_runtime_dependency('ferrum', '~> 0.9')
  spec.add_runtime_dependency('fit4ruby', '= 3.7')
  spec.add_runtime_dependency('nokogiri', '~> 1.10')
  spec.add_runtime_dependency('ruby-duration', '~> 3.2')
  spec.add_runtime_dependency('ruby-vips', '~> 2.0')
  spec.add_runtime_dependency('timeliness', '~> 0.4')
  spec.add_runtime_dependency('word_wrap', '~> 1.0')
  spec.add_development_dependency('rubocop', '~> 1.2')
end
