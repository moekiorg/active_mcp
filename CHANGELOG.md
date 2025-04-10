# Changelog

All notable changes to Active MCP will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.10.9] - 2025-04-10

- Fix default server version

## [0.10.8] - 2025-04-10

- Improve parameter between mcp server and rails

## [0.10.7] - 2025-04-09

- Fix schema methods

## [0.10.6] - 2025-04-09

- Fix autoloading
- Fix accept header of request to rails

## [0.10.5] - 2025-04-09

- Pass context to complete function

## [0.10.4] - 2025-04-09

- Fix resource template structure

## [0.10.3] - 2025-04-09

- Fix no argument prompt list

## [0.10.2] - 2025-04-09

- Fix prompt argument completion

## [0.10.1] - 2025-04-09

- Fix arguments of prompt argument

## [0.10.0] - 2025-04-09

- Change interface of schema and prompt

## [0.9.3] - 2025-04-08

- Fix response parsing

## [0.9.2] - 2025-04-08

- Add code coverage analytics
- Improve code coverage

## [0.9.0] - 2025-04-08

### Added

- Add MCP Prompts primitive
- Add Completion feature

## [0.3.0] - 2025-04-06

### Added

- New `install` generator for easy setup (`rails generate active_mcp:install`)
- Configuration system with initializer template
- MCP server script generation for production deployments
- Comprehensive documentation for generators
- Updated README with installation and usage instructions

### Changed

- Improved tool generator to place files in the configured tools directory
- Updated documentation to reflect new setup process

## [0.2.1] - 2025-04-05

### Fixed

- Fixed bug in authentication header parsing
- Improved error handling for invalid tool parameters

## [0.2.0] - 2025-04-01

### Added

- Authorization control for MCP tools using `authorized?` class method
- Tool filtering based on authentication context in tools/list endpoint
- Access control for tool execution in tools/call endpoint
- Comprehensive tests for authorization features
- Documentation for authorization capabilities

### Changed

- Improved security by validating tool access permissions
- Updated tool generator to include authorization example

## [0.1.1] - 2025-03-21

### Added

- Initial release
- Basic MCP tools implementation
- Rails engine integration
- Tool generators
- Authentication handling
