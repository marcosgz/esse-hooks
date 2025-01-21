# frozen_string_literal: true

require_relative "lib/esse/hooks/version"

Gem::Specification.new do |spec|
  spec.name = "esse-hooks"
  spec.version = Esse::Hooks::VERSION
  spec.authors = ["Marcos G. Zimmermann"]
  spec.email = ["mgzmaster@gmail.com"]

  spec.summary = "Hooks extensions for Esse"
  spec.description = "A set of hooks extensions for Esse, the Ruby ElasticSearch and OpenSearch client."
  spec.homepage = "https://github.com/marcosgz/esse-hooks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/marcosgz/esse-hooks"
  spec.metadata["changelog_uri"] = "https://github.com/marcosgz/esse-hooks/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "esse", ">= 0.3.0"
end
