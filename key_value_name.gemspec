# -*- encoding: utf-8 -*-
# frozen_string_literal: true

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'key_value_name/version'

Gem::Specification.new do |s|
  s.name              = 'key_value_name'
  s.version           = KeyValueName::VERSION
  s.platform          = Gem::Platform::RUBY
  s.authors           = ['John Lees-Miller']
  s.email             = ['jdleesmiller@gmail.com']
  s.homepage          = 'https://github.com/jdleesmiller/key_value_name'
  s.summary           = 'Store key-value pairs in file names, e.g.' \
                        ' parameter names and parameters.'
  s.description       = 'Store key-value pairs in file names, e.g.' \
                        ' parameter names and parameters.'

  s.add_development_dependency 'gemma', '~> 4.1.0'

  s.files       = Dir.glob('{lib,bin}/**/*.rb') + %w(README.md)
  s.test_files  = Dir.glob('test/key_value_name/*_test.rb')

  s.rdoc_options = [
    '--main', 'README.md',
    '--title', "#{s.full_name} Documentation"
  ]
  s.extra_rdoc_files << 'README.md'
end
