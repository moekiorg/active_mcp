ActiveMcp::Engine.routes.draw do
  post "/", to: "base#index"
  get "/health", to: proc { [200, {}, ["OK"]] }
end
