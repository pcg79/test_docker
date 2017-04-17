# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cz/version'

Gem::Specification.new do |spec|
  spec.name          = 'cz'
  spec.version       = CZ::VERSION
  spec.authors       = ['Ernie Miller', 'Pat George']
  spec.email         = ['ernie@carezone.com', 'pat@carezone.com']

  spec.summary       = %q{CareZone CLI tool}
  spec.description   = %q{Create, configure, and deploy apps at CareZone.}
  spec.homepage      = 'https://carezone.com'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gems.czops.net'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'google-api-client', '~> 0.10.1'
  spec.add_dependency 'gpgme', '~> 2.0.12'
  spec.add_dependency 'net-ssh', '~> 4.1.0'
  spec.add_dependency 'parallel', '~> 1.10.0'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'geminabox-release', '~> 0.2.0'
  spec.add_development_dependency 'guard', '~> 2.14.1'
  spec.add_development_dependency 'guard-minitest', '~> 2.4.6'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'terminal-notifier-guard', '~> 1.7.0'
end
