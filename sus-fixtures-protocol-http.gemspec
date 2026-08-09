# frozen_string_literal: true

require_relative "lib/sus/fixtures/protocol/http/version"

Gem::Specification.new do |spec|
	spec.name = "sus-fixtures-protocol-http"
	spec.version = Sus::Fixtures::Protocol::HTTP::VERSION
	
	spec.summary = "Test fixtures for Protocol::HTTP middleware."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/sus-fixtures-protocol-http"
	
	spec.metadata = {
		"bug_tracker_uri" => "https://github.com/socketry/sus-fixtures-protocol-http/issues",
		"changelog_uri" => "https://github.com/socketry/sus-fixtures-protocol-http/blob/main/releases.md",
		"documentation_uri" => "https://socketry.github.io/sus-fixtures-protocol-http/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/socketry/sus-fixtures-protocol-http.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.3"
	
	spec.add_dependency "protocol-http", "~> 0.68"
	spec.add_dependency "sus", "~> 0.37"
end
