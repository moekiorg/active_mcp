class DummyResource < ActiveMcp::Resource::Base
  resource_template_name "dummy"

  uri_template "data://app/users/{name}"

  mime_type "application/json"

  argument :name, complete: ->(value, _) do
    ["UserA", "UserB"].filter { _1.match(value) }
  end

  def initialize(name:)
    @name = name
  end

  def resource_name
    @name
  end

  def uri
    "data://app/users/#{@name}"
  end

  def description
    "This is a dummy"
  end

  def text
    "Hello! #{@name}"
  end
end
