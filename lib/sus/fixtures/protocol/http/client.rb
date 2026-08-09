# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "protocol/http/cookie"
require "protocol/http/middleware"
require "protocol/http/request"
require "uri"

module Sus
	module Fixtures
		module Protocol
			module HTTP
				# An in-process client for exercising protocol HTTP middleware.
				class Client < ::Protocol::HTTP::Middleware
					# Initialize the client.
					#
					# @parameter delegate [::Protocol::HTTP::Middleware] The middleware to exercise.
					# @parameter scheme [String] The default request scheme.
					# @parameter authority [String] The default request authority.
					def initialize(delegate, scheme: "http", authority: "localhost")
						super(delegate)
						
						@scheme = scheme
						@authority = authority
						
						@headers = {}
						@cookies = {}
						@closed = false
						@exchange_closed = true
					end
					
					# @attribute [String] The default request scheme.
					attr :scheme
					
					# @attribute [String] The default request authority.
					attr :authority
					
					# @attribute [Hash(String, String)] Headers added to every request.
					attr :headers
					
					# @attribute [Hash(String, String)] Cookies retained between requests.
					attr :cookies
					
					# @attribute [::Protocol::HTTP::Request | Nil] The most recent request.
					attr :last_request
					
					# @attribute [::Protocol::HTTP::Response | Nil] The most recent response.
					attr :last_response
					
					# Set a default request header.
					#
					# @parameter name [String] The header name.
					# @parameter value [String] The header value.
					def header(name, value)
						@headers[name.downcase] = value
					end
					
					# Store a cookie for subsequent requests.
					#
					# @parameter value [String | ::Protocol::HTTP::Cookie] The cookie to store.
					def set_cookie(value)
						case value
						when String
							cookie = ::Protocol::HTTP::Cookie.parse(value)
						when ::Protocol::HTTP::Cookie
							cookie = value
						else
							raise ArgumentError, "Unsupported cookie: #{value.inspect}"
						end
						
						if cookie.value
							@cookies[cookie.name] = cookie.value
						else
							@cookies.delete(cookie.name)
						end
						
						return cookie
					end
					
					# Construct and perform a request.
					#
					# @parameter method [String] The request method.
					# @parameter path [String] The request path.
					# @parameter headers [Hash | ::Protocol::HTTP::Headers | Nil] The request headers.
					# @parameter body [String | Array(String) | ::Protocol::HTTP::Body::Readable | Nil] The request body.
					# @parameter options [Hash] Additional options for {::Protocol::HTTP::Request.[]}.
					# @returns [::Protocol::HTTP::Response] The application response.
					def request(method, path, headers = nil, body = nil, **options)
						return self.call(
							::Protocol::HTTP::Request[method, path, headers, body, **options]
						)
					end
					
					# Perform a prepared request against the application.
					#
					# @parameter request [::Protocol::HTTP::Request] The prepared request.
					# @returns [::Protocol::HTTP::Response] The application response.
					def call(request)
						if @closed
							raise IOError, "Client is closed!"
						end
						
						self.close_exchange
						self.prepare_request(request)
						
						@last_request = request
						@last_response = nil
						@exchange_closed = false
						
						begin
							@last_response = super(request)
							self.store_cookies(@last_response.headers["set-cookie"])
							
							return @last_response
						rescue => error
							self.close_exchange(error)
							raise
						end
					end
					
					# Follow the location in the most recent redirect response.
					#
					# Statuses 307 and 308 preserve the original method and body. Other redirects use `GET`, except that `HEAD` remains `HEAD`.
					#
					# @returns [::Protocol::HTTP::Response] The redirected response.
					def follow_redirect!
						response = @last_response
						request = @last_request
						
						unless response&.redirection?
							raise RuntimeError, "The last response is not a redirect!"
						end
						
						location = response.headers["location"]
						unless location
							raise RuntimeError, "The redirect response has no location!"
						end
						
						base = "#{request.scheme}://#{request.authority}#{request.path}"
						target = ::URI.join(base, location.to_s)
						
						if response.preserve_method?
							if @request_had_body && !@replay_body
								raise IOError, "The request body cannot be replayed!"
							end
							
							method = request.method
							body = @replay_body
						elsif request.head?
							method = ::Protocol::HTTP::Methods::HEAD
							body = nil
						else
							method = ::Protocol::HTTP::Methods::GET
							body = nil
						end
						
						return self.request(
							method,
							target.request_uri,
							nil,
							body,
							scheme: target.scheme,
							authority: target.authority,
						)
					end
					
					# Close the current exchange and application.
					#
					# @parameter error [Exception | Nil] The error which caused the client to close.
					def close(error = nil)
						return if @closed
						
						@closed = true
						
						begin
							self.close_exchange(error)
						ensure
							super()
						end
					end
					
					private
					
					def prepare_request(request)
						request.scheme ||= @scheme
						request.authority ||= @authority
						
						@headers.each do |name, value|
							unless request.headers.include?(name)
								request.headers[name] = value
							end
						end
						
						if !@cookies.empty? && !request.headers.include?("cookie")
							request.headers["cookie"] = @cookies.map{|name, value| "#{name}=#{value}"}
						end
						
						@request_had_body = request.body?
						@replay_body = request.body&.buffered
					end
					
					def store_cookies(values)
						return unless values
						
						values.to_h.each_value do |cookie|
							self.set_cookie(cookie)
						end
					end
					
					def close_exchange(error = nil)
						return if @exchange_closed
						
						begin
							@last_response&.close(error)
						ensure
							@last_request&.close(error)
							@exchange_closed = true
						end
					end
				end
			end
		end
	end
end
