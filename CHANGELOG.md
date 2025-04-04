# Changelog

All notable changes to Active MCP will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-04-05

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
