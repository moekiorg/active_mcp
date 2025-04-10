class ImageResource < ActiveMcp::Resource::Base
  mime_type "image/png"

  def resource_name
    "image"
  end

  def uri
    "data://localhost/image"
  end

  def description
    "Lena's photo"
  end

  def blob
    File.read(Rails.root.join("public", "lena.png"))
  end
end
