require_relative 'lib/stow_man/version'

Gem::Specification.new do |spec|
  spec.name = 'stow_man'
  spec.version = StowMan::VERSION
  spec.authors = ['Jorge']
  spec.email = ['jorge@example.com']

  spec.summary = 'Manage dotfiles with GNU Stow'
  spec.description = 'Executable Ruby gem to manage dotfiles and app configs using GNU Stow.'
  spec.homepage = 'https://example.com/stow_man'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.glob('{exe,lib,test}/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  spec.bindir = 'exe'
  spec.executables = ['stow-man']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
end
