# Getting Started

This guide explains how to exercise {ruby Protocol::HTTP::Middleware} directly, without starting a server.

## Installation

Add the gem to your project:

``` bash
$ bundle add sus-fixtures-protocol-http --group test
```

## Middleware Context

Include {ruby Sus::Fixtures::Protocol::HTTP::MiddlewareContext} and provide the middleware under test:

``` ruby
require "sus/fixtures/protocol/http/middleware_context"

describe MyMiddleware do
	include Sus::Fixtures::Protocol::HTTP::MiddlewareContext
	
	let(:middleware) {MyMiddleware.new}
	
	it "serves the index" do
		response = client.get("/")
		
		expect(response.status).to be == 200
		expect(response.read).to be == "Hello World!"
	end
end
```

The client calls the middleware directly. Use `sus-fixtures-async-http` when a test needs real HTTP transport behavior.

## Requests

The client supports the methods defined by {ruby Protocol::HTTP::Methods}, including `get`, `post`, `put`, `patch`, `delete`, and `query`:

``` ruby
response = client.post(
	"/users",
	{"content-type" => "application/json"},
	'{"name":"Samuel"}',
)
```

Use {ruby Sus::Fixtures::Protocol::HTTP::Client#request} for extension methods:

``` ruby
response = client.request("CUSTOM", "/resource")
```

## Stateful Requests

Default headers and cookies are retained across requests:

``` ruby
client.header("accept", "application/json")
client.set_cookie("session=abc123")

response = client.get("/account")
```

Response cookies are stored automatically. Redirects can be followed explicitly:

``` ruby
client.get("/old-location")
client.follow_redirect!
```

The client closes the previous request and response before starting another exchange. The middleware context closes both the final exchange and the middleware after each test.
