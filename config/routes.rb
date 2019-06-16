Rails.application.routes.draw do
  resources :users, except: %w(show)
  resource :sessions, as: :login, path: :login, only: %w(new create)
  resource :sessions, as: :logout, path: :logout, only: %w(destroy)

  root to: 'sessions#new'
end
