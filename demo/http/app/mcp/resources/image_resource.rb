class ImageResource
  class << self
    def mime_type
      "image/png"
    end
  end

  def name
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
