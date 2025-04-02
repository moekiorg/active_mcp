Rails.application.routes.draw do
  mount ActiveMcp::Engine => "/mcp"

  post "/secure_mcp", to: "custom#index"
end
