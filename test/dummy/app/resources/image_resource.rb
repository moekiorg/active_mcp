class ImageResource < ActiveMcp::Resource
  uri "data://localhost/image"
  mime_type "image/png"
  description "Lena's photo"

  def blob(auth_info: nil)
    File.read(Rails.root.join("public", "lena.png"))
  end
end
