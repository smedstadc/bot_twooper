# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bot_twooper/version'

Gem::Specification.new do |spec|
  spec.name          = "bot_twooper"
  spec.version       = BotTwooper::VERSION
  spec.authors       = ["Corey Smedstad"]
  spec.email         = ["smedstadc@gmail.com"]

  spec.summary       = "A jabber channel bot for Eve: Online corps."
  spec.homepage      = "https://github.com/smedstadc/bot_twooper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "blather", "~> 1.2"
  spec.add_dependency "sequel", "~> 4"
  spec.add_dependency "sqlite3", "~> 1.3"
  spec.add_dependency "rest-client"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
