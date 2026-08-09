# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/fixtures/protocol/http/middleware_context"

describe Sus::Fixtures::Protocol::HTTP::Client do
	include Sus::Fixtures::Protocol::HTTP::MiddlewareContext
	
	it "performs requests against protocol HTTP middleware" do
		response = client.get("/")
		
		expect(response.status).to be == 200
		expect(response.read).to be == "Hello World!"
		expect(last_request.method).to be == "GET"
	end
	
	it "assigns the default request origin" do
		client.get("/")
		
		expect(last_request.scheme).to be == "http"
		expect(last_request.authority).to be == "localhost"
	end
	
	it "closes the previous exchange" do
		response = client.get("/")
		client.get("/")
		
		expect(response.body?).to be_nil
	end
	
	with "request metadata" do
		let(:middleware) do
			::Protocol::HTTP::Middleware.for do |request|
				::Protocol::HTTP::Response[
					200,
					{},
					["#{request.method} #{request.path} #{request.headers["x-default"]} #{request.headers["x-request"]}"],
				]
			end
		end
		
		it "combines default and request headers" do
			client.headers["x-default"] = "default"
			response = client.post("/items", {"x-request" => "request"}, "content")
			
			expect(response.read).to be == "POST /items default request"
		end
		
		it "allows request headers to override defaults" do
			client.headers["x-default"] = "default"
			response = client.get("/", {"x-default" => "override"})
			
			expect(response.read).to be == "GET / override "
		end
	end
	
	with "cookies" do
		let(:middleware) do
			::Protocol::HTTP::Middleware.for do |request|
				if request.path == "/set"
					::Protocol::HTTP::Response[200, {"set-cookie" => "session=abc123; Path=/"}]
				else
					::Protocol::HTTP::Response[200, {}, [request.headers["cookie"].to_s]]
				end
			end
		end
		
		it "retains response cookies" do
			client.get("/set")
			response = client.get("/show")
			
			expect(response.read).to be == "session=abc123"
		end
		
		it "accepts explicit cookies" do
			client.set_cookie("user=samuel")
			response = client.get("/show")
			
			expect(response.read).to be == "user=samuel"
		end
		
		it "removes cookies without values" do
			client.set_cookie("user=samuel")
			client.set_cookie("user")
			response = client.get("/show")
			
			expect(response.read).to be_nil
		end
		
		it "rejects unsupported cookie values" do
			expect do
				client.set_cookie(Object.new)
			end.to raise_exception(ArgumentError, message: be =~ /Unsupported cookie/)
		end
	end
	
	with "redirects" do
		let(:middleware) do
			::Protocol::HTTP::Middleware.for do |request|
				case request.path
				when "/redirect"
					::Protocol::HTTP::Response[302, {"location" => "/target"}]
				when "/preserve"
					::Protocol::HTTP::Response[307, {"location" => "/target"}]
				else
					::Protocol::HTTP::Response[200, {}, ["#{request.method} #{request.path} #{request.read}"]]
				end
			end
		end
		
		it "follows a redirect using GET" do
			client.post("/redirect", {}, "content")
			response = client.follow_redirect!
			
			expect(response.read).to be == "GET /target "
		end
		
		it "preserves the method and body when required" do
			client.post("/preserve", {}, "content")
			response = client.follow_redirect!
			
			expect(response.read).to be == "POST /target content"
		end
		
		it "preserves HEAD requests" do
			client.head("/redirect")
			client.follow_redirect!
			
			expect(last_request.method).to be == "HEAD"
		end
		
		it "rejects non-replayable request bodies" do
			client.post("/preserve", {}, ::Protocol::HTTP::Body::Readable.new)
			
			expect do
				client.follow_redirect!
			end.to raise_exception(IOError, message: be == "The request body cannot be replayed!")
		end
		
		it "requires a redirect response" do
			client.get("/target")
			
			expect do
				client.follow_redirect!
			end.to raise_exception(RuntimeError, message: be == "The last response is not a redirect!")
		end
	end
	
	with "a redirect without a location" do
		let(:middleware) do
			::Protocol::HTTP::Middleware.for do |_request|
				::Protocol::HTTP::Response[302]
			end
		end
		
		it "cannot follow the redirect" do
			client.get("/")
			
			expect do
				client.follow_redirect!
			end.to raise_exception(RuntimeError, message: be == "The redirect response has no location!")
		end
	end
	
	with "failing middleware" do
		let(:middleware) do
			::Protocol::HTTP::Middleware.for do |_request|
				raise "Broken middleware!"
			end
		end
		
		it "closes the failed request" do
			expect do
				client.post("/", {}, "content")
			end.to raise_exception(RuntimeError, message: be == "Broken middleware!")
			
			expect(last_request.body?).to be_nil
		end
	end
	
	it "supports arbitrary request methods" do
		client.request("CUSTOM", "/custom")
		
		expect(last_request.method).to be == "CUSTOM"
	end
	
	it "rejects requests after closing" do
		client.close
		
		expect do
			client.get("/")
		end.to raise_exception(IOError, message: be == "Client is closed!")
	end
end
