Rails.application.routes.draw do
  post "/mcp", to: "mcp#index"

  post "/secure", to: "custom#index"
end
