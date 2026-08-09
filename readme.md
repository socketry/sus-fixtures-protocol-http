# Sus::Fixtures::Protocol::HTTP

Provides transport-free test fixtures for <code class="language-ruby">Protocol::HTTP::Middleware</code> applications.

[![Development Status](https://github.com/socketry/sus-fixtures-protocol-http/workflows/Test/badge.svg)](https://github.com/socketry/sus-fixtures-protocol-http/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/sus-fixtures-protocol-http/) for more details.

  - [Getting Started](https://socketry.github.io/sus-fixtures-protocol-http/guides/getting-started/index) - This guide explains how to exercise <code class="language-ruby">Protocol::HTTP::Middleware</code> directly, without starting a server.

## Releases

Please see the [project releases](https://socketry.github.io/sus-fixtures-protocol-http/releases/index) for all releases.

### v0.1.0

  - Introduce an in-process client and middleware context for protocol HTTP middleware.

## Contributing

We welcome contributions to this project.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature.'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create a new pull request.

### Running Tests

To run the test suite:

``` shell
bundle exec sus
```

### Making Releases

To make a new release:

``` shell
bundle exec bake gem:release:patch # or minor or major
```

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
