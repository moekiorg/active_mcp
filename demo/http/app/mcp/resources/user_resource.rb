class UserResource < ActiveMcp::Resource::Base
  class << self
    def resource_template_name
      "User"
    end

    def uri_template
      "data://localhost/user/{name}"
    end

    def mime_type
      "application/json"
    end

    def description
      "The user's profile"
    end
  end

  argument :name, ->(value) do
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
    { name: @name }
  end
end
