# Schemas

Schemas define what tools, resources, and prompts are available to AI assistants. They also handle visibility and access control.

## Creating a Schema

Create a schema by inheriting from `ActiveMcp::Schema::Base`:

```ruby
class MySchema < ActiveMcp::Schema::Base
  # Register tools
  tool SearchUsersTool
  tool CreateUserTool
  
  # Register resources with their instances
  resource UserResource, items: User.all.map { |user| 
    { id: user.id } 
  }
  
  # Register prompts
  prompt WelcomePrompt
end
```

## Schema Components

A schema can contain:

1. **Tools**: Executable functions that AI can call
2. **Resources**: Data and files that AI can access
3. **Prompts**: Pre-defined message templates

## Schema Context

Schemas receive a context object that includes authentication information:

```ruby
context = {
  auth_info: {
    type: :bearer,
    token: "user-token",
    header: "Bearer user-token"
  }
}

schema = MySchema.new(context: context)
```

## Visibility Control

The schema filters components based on their visibility rules:

```ruby
def visible_tools
  self.class.tools&.filter do |tool|
    !tool.respond_to?(:visible?) || tool.visible?(context: @context)
  end
end

def visible_resources
  visibles = self.class.resources&.filter do |resource|
    !resource[:klass].respond_to?(:visible?) || 
      resource[:klass].visible?(context: @context)
  end
  
  visibles&.map do |resource|
    resource[:items].map { |item| resource[:klass].new(**item) }
  end&.flatten || []
end
```

## Using in Controllers

Use schemas in your MCP controller:

```ruby
class MyMcpController < ActiveMcp::BaseController
  private

  def schema
    MySchema.new(context:)
  end
end
```