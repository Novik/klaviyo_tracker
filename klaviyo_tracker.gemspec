lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "klaviyo_tracker/version"

Gem::Specification.new do |spec|
  spec.name          = "klaviyo_tracker"
  spec.version       = KlaviyoTracker::VERSION
  spec.authors       = ["Novik"]
  spec.email         = ["novik65@gmail.com"]

  spec.summary       = "Add spree orders tracking for Klaviyo".freeze
  spec.homepage = "https://github.com/Novik/klaviyo_tracker".freeze

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"

  spec.add_dependency(%q<spree_core>.freeze, ["~> 3.0.1"])
#  spec.add_dependency "klaviyo" # use Gemfile for include https://github.com/klaviyo/ruby-klaviyo
end
