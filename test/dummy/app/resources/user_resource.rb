class UserResource < ActiveMcp::Resource
  uri "data://localhost/user"
  mime_type "application/json"
  description "User"

  def text(auth_info: nil)
    { foo: "bar" }
  end

  # def blob(auth_info: nil)
  #   File.read("/path/to/file")
  # end
end
