# frozen_string_literal: true

require_relative "lib/famitracker_parser/version"

Gem::Specification.new do |spec|
  spec.name = "famitracker_parser"
  spec.version = FamitrackerParser::VERSION
  spec.authors = ["Wendel Scardua"]
  spec.email = ["wendelscardua@gmail.com"]

  spec.summary = "Ruby FamiTracker text parser."
  spec.description = "Ruby gem for parsing text files exported from FamiTracker"
  spec.homepage = "http://github.com/wendelscardua/famitracker_parser"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "treetop", "~> 1.6.11"
end
