Rails.application.routes.draw do
  get 'leave_types/resources'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  get '/home', to: 'home#home'
  resources :leave_types
end
