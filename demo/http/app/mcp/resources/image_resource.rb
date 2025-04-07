class ImageResource
  def name
    "image"
  end

  def uri
    "data://localhost/image"
  end
  
  def mime_type
    "image/png"
  end

  def description
    "Lena's photo"
  end

  def blob
    File.read(Rails.root.join("public", "lena.png"))
  end
end
