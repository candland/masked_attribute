require_relative "lib/masked_attribute/version"

Gem::Specification.new do |spec|
  spec.name = "masked_attribute"
  spec.version = MaskedAttribute::VERSION
  spec.authors = ["candland"]
  spec.email = ["candland@gmail.com"]
  spec.homepage = "https://candland.net/masked_attribute"
  spec.summary = "Adds methods for a bit masked field"
  spec.description = "Adds methods for a bit masked field"
  spec.license = "MIT"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/candland/masked_attribute"
  spec.metadata["changelog_uri"] = "https://github.com/candland/masked_attribute/CHANGES.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.4.2"
end
