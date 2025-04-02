Rails.application.routes.draw do
  mount ActiveMcp::Engine => "/mcp"

  post "/secure", to: "custom#index"
end
