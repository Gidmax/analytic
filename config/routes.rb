Rails.application.routes.draw do
  resources :trackers
  resources :services
  devise_for :users
  resources :postcards

  # home page
  get 'home/test'
  get 'home/index'
  get 'home/auth_storing'
  get "mod/:title", to: "home#mod"

  # landing page
  get 'landing/index'
  get "about", to: "landing#about"
  get "our-project", to: "landing#our_project"
  get "oauth2callback", to: "landing#callback"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'landing#index'
end
