class UserResource < ActiveMcp::Resource::Base
  resource_template_name "User"

  uri_template "data://localhost/user/{name}"

  mime_type "application/json"

  description "The user's profile"

  argument :name, complete: ->(value) do
    ["UserA", "UserB"].filter { _1.match(value) }
  end

  def initialize(name:)
    @name = name
  end

  def resource_name
    @name
  end

  def uri
    "data://localhost/user/#{@name}"
  end

  def description
    "#{@name}'s profile"
  end

  def text
    {name: @name}
  end
end
