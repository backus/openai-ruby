# frozen_string_literal: true

require File.expand_path('lib/openai/version', __dir__)

Gem::Specification.new do |spec|
  spec.name        = 'openai.rb'
  spec.version     = OpenAI::VERSION
  spec.authors     = %w[John Backus]
  spec.email       = %w[johncbackus@gmail.com]

  spec.summary     = 'OpenAI Ruby Wrapper'
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/backus/openai-ruby'

  spec.files         = `git ls-files`.split("\n")
  spec.require_paths = %w[lib]
  spec.executables   = []

  spec.required_ruby_version = '>= 3.2'

  spec.add_dependency 'abstract_type', '~> 0.0.7'
  spec.add_dependency 'anima',         '~> 0.3'
  spec.add_dependency 'concord',       '~> 0.1'
  spec.add_dependency 'http',          '>= 4.4', '< 6.0'
  spec.add_dependency 'ice_nine',      '~> 0.11.x'
  spec.add_dependency 'memoizable',    '~> 0.4.2'
  spec.add_dependency 'tiktoken_ruby', '~> 0.0.6'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
