
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "query_generator/version"

Gem::Specification.new do |spec|
  spec.name          = "query_generator"
  spec.version       = QueryGenerator::VERSION
  spec.authors       = ["aimerald"]
  spec.email         = [""]

  spec.summary       = %q{Generate Standard SQL Query}
  spec.description   = %q{Generate Standard Sql query}
  spec.homepage      = "https://github.com/aimerald/query_generator"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
