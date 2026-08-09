# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/fixtures/protocol/http/middleware_context"

describe Sus::Fixtures::Protocol::HTTP::MiddlewareContext do
	include Sus::Fixtures::Protocol::HTTP::MiddlewareContext
	
	it "provides a middleware client" do
		expect(client).to be_a(Sus::Fixtures::Protocol::HTTP::Client)
	end
	
	it "provides access to the latest exchange" do
		response = client.get("/")
		
		expect(last_request.path).to be == "/"
		expect(last_response).to be == response
	end
end
