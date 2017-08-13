Rails.application.routes.draw do
  resources :services
  devise_for :users
  resources :postcards

  get 'home/test'
  get 'home/index'
  get 'landing/about'

  get 'landing/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'landing#index'
end
