# -*- encoding: utf-8 -*-
# stub: cz 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "cz".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://gems.czops.net" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ernie Miller".freeze, "Pat George".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-03-03"
  s.description = "Create, configure, and deploy apps at CareZone.".freeze
  s.email = ["ernie@carezone.com".freeze, "pat@carezone.com".freeze]
  s.executables = ["cz".freeze, "receive-cz-deploy".freeze]
  s.files = ["exe/cz".freeze, "exe/receive-cz-deploy".freeze]
  s.homepage = "https://carezone.com".freeze
  s.rubygems_version = "2.6.10".freeze
  s.summary = "CareZone CLI tool".freeze

  s.installed_by_version = "2.6.10" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gpgme>.freeze, ["~> 2.0.12"])
      s.add_runtime_dependency(%q<net-ssh>.freeze, ["~> 4.1.0"])
      s.add_runtime_dependency(%q<parallel>.freeze, ["~> 1.10.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.13"])
      s.add_development_dependency(%q<guard>.freeze, ["~> 2.14.1"])
      s.add_development_dependency(%q<guard-minitest>.freeze, ["~> 2.4.6"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<terminal-notifier-guard>.freeze, ["~> 1.7.0"])
    else
      s.add_dependency(%q<gpgme>.freeze, ["~> 2.0.12"])
      s.add_dependency(%q<net-ssh>.freeze, ["~> 4.1.0"])
      s.add_dependency(%q<parallel>.freeze, ["~> 1.10.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.13"])
      s.add_dependency(%q<guard>.freeze, ["~> 2.14.1"])
      s.add_dependency(%q<guard-minitest>.freeze, ["~> 2.4.6"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<terminal-notifier-guard>.freeze, ["~> 1.7.0"])
    end
  else
    s.add_dependency(%q<gpgme>.freeze, ["~> 2.0.12"])
    s.add_dependency(%q<net-ssh>.freeze, ["~> 4.1.0"])
    s.add_dependency(%q<parallel>.freeze, ["~> 1.10.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.13"])
    s.add_dependency(%q<guard>.freeze, ["~> 2.14.1"])
    s.add_dependency(%q<guard-minitest>.freeze, ["~> 2.4.6"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<terminal-notifier-guard>.freeze, ["~> 1.7.0"])
  end
end
