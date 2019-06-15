Rails.application.routes.draw do
  resources :users, except: %w(show)
end
