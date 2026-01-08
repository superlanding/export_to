
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "export_to/version"

Gem::Specification.new do |spec|
  spec.name          = "export_to"
  spec.version       = ExportTo::VERSION
  spec.authors       = ["eddie"]
  spec.email         = ["eddie.li.624@gmail.com"]

  spec.summary       = %q{Export activerecord easiest way (csv, xls, xlsx)}
  spec.description   = %q{Export activerecord easiest way (csv, xls, xlsx)}
  spec.homepage      = "https://github.com/superlanding/export_to"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7.0", "< 3.4.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.0.0"
  spec.add_development_dependency "rake", ">= 13"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "shoulda-context"

  spec.add_dependency "fast_excel", "~> 0.4"
  spec.add_dependency "spreadsheet", "~> 1.3"
  spec.add_dependency "iconv", "~> 1.0"
  spec.add_dependency "activesupport", ">= 6.0", "< 8"
end
