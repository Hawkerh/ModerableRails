# frozen_string_literal: true

require_relative "lib/Moderable/version"

Gem::Specification.new do |spec|
  spec.name = "Moderable"
  spec.version = Moderable::VERSION
  spec.authors = ["Hawkerh"]
  spec.email = ["cissealbert.d@icloud.com"]

  spec.summary = "Une brève description de Moderable."
  spec.description = "..."
  spec.homepage = "https://github.com/Hawkerh/ModerableRails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = "https://github.com/Hawkerh/ModerableRails"
  spec.metadata["source_code_uri"] = "https://github.com/Hawkerh/ModerableRails"
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "rails", "~> 5.2"

  # Dépendances de développement
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
