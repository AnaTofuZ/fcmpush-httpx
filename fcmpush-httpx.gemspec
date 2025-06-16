# frozen_string_literal: true

require_relative "lib/fcmpush/httpx/version"

Gem::Specification.new do |spec|
  spec.name = "fcmpush-httpx"
  spec.version = Fcmpush::Httpx::VERSION
  spec.authors = ["anatofuz"]
  spec.email = ["anatofuz@gmail.com"]

  spec.summary = "'Firebase Cloud Messaging API wrapper for ruby, supports HTTP v1 using httpx gem.'"
  spec.description = "Firebase Cloud Messaging API wrapper for ruby, supports HTTP v1 using httpx gem. It includes access_token auto-refresh feature and is designed to be simple and easy to use."
  spec.homepage = "https://github.com/AnaTofuZ/fcmpush-httpx"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/AnaTofuZ/fcmpush-httpx"
  spec.metadata["changelog_uri"] = "https://github.com/AnaTofuZ/fcmpush-httpx/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile flake gemset.nix])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httpx", "~> 1.5"
  spec.add_dependency 'google-apis-identitytoolkit_v3', "~> 0.18.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
