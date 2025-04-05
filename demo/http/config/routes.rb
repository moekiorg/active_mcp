Rails.application.routes.draw do
  mount ActiveMcp::Engine, at: '/mcp'

  post "/secure", to: "custom#index"
end
