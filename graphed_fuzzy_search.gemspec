
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphed_fuzzy_search/version"

Gem::Specification.new do |spec|
  spec.name          = "graphed_fuzzy_search"
  spec.version       = GraphedFuzzySearch::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["sorah@cookpad.com"]

  spec.summary       = %q{filter items like Slack switcher, Atom command palette}
  spec.homepage      = "https://github.com/sorah/graphed_fuzzy_search"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
