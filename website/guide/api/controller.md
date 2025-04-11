# Controller

The `ActiveMcp::BaseController` provides the core functionality for handling MCP requests in your Rails application.

## Basic Usage

Create a controller that inherits from `ActiveMcp::BaseController`:

```ruby
class MyMcpController < ActiveMcp::BaseController
  private

  def schema
    MySchema.new(context:)
  end
end
```
