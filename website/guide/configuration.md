---
title: Configuration
description: Configuring Active MCP for your Rails application
---

# Configuration

After installing Active MCP, you'll need to configure it to match your application's needs. This guide covers the various configuration options available.

### Initializer Options

The initializer at `config/initializers/active_mcp.rb` contains more detailed configuration:

```ruby
ActiveMcp.configure do |config|
  config.server_name = "MCP Server"
  config.server_version = "1.0.0"
end
```

Now that you've configured Active MCP, learn how to use it in your application by checking out the [Basic Usage](./basic-usage) guide.
