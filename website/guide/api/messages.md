# Messages

Active MCP supports various message content types for communication between AI assistants and your application.

## Message Types

### 1. Text Messages

Basic text content:

```ruby
{
  type: "text",
  text: "Hello world"
}
```

### 2. Image Messages

Binary image data with MIME type:

```ruby
{
  type: "image",
  data: binary_data,
  mimeType: "image/png"
}
```

### 3. Audio Messages

Binary audio data with MIME type:

```ruby
{
  type: "audio",
  data: binary_data,
  mimeType: "audio/mpeg"
}
```

### 4. Resource Messages

References to MCP resources:

```ruby
{
  type: "resource",
  resource: {
    uri: "data://app/resources/123",
    mimeType: "application/json",
    text: "Resource content"
  }
}
```

## Message Helpers

Active MCP provides helper classes for creating messages:

```ruby
# Text message
ActiveMcp::Message::Text.new(
  role: "user",
  text: "Hello"
).to_h

# Image message
ActiveMcp::Message::Image.new(
  role: "user",
  data: image_data,
  mime_type: "image/png"
).to_h

# Audio message
ActiveMcp::Message::Audio.new(
  role: "user",
  data: audio_data,
  mime_type: "audio/mpeg"
).to_h

# Resource message
ActiveMcp::Message::Resource.new(
  role: "user",
  resource: user_resource
).to_h
```

## Role Types

Messages can have the following roles:

- `user`: Messages from the user to the AI
- `assistant`: Messages from the AI to the user

## Content Format

All message types follow this basic structure:

```ruby
{
  role: "user" | "assistant",
  content: {
    type: "text" | "image" | "audio" | "resource",
    # Type-specific fields
  }
}
```
