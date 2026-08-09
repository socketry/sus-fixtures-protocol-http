# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "protocol/http/middleware"
require_relative "client"

module Sus
	module Fixtures
		module Protocol
			module HTTP
				# A test context for exercising a protocol HTTP middleware application in-process.
				module ApplicationContext
					# The middleware application under test.
					#
					# @returns [::Protocol::HTTP::Middleware] The middleware application.
					def app
						::Protocol::HTTP::Middleware::HelloWorld
					end
					
					# The in-process client for the application.
					#
					# @returns [Client] The client.
					def client
						@client ||= Client.new(app)
					end
					
					# The most recent request.
					#
					# @returns [::Protocol::HTTP::Request | Nil] The request.
					def last_request
						client.last_request
					end
					
					# The most recent response.
					#
					# @returns [::Protocol::HTTP::Response | Nil] The response.
					def last_response
						client.last_response
					end
					
					# Close the client after each test.
					#
					# @parameter error [Exception | Nil] The error raised by the test, if any.
					def after(error = nil)
						begin
							@client&.close(error)
						ensure
							super
						end
					end
				end
			end
		end
	end
end
