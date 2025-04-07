class UserResource
  def initialize(name:)
    @name = name
    @auth_info = auth_info
  end

  def name
    @name
  end

  def uri
    "data://localhost/user/#{@name}"
  end

  def mime_type
    "application/json"
  end

  def description
    "ほげほげ"
  end

  def text
    { name: @name }
  end
end
