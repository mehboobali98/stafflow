Rails.application.routes.draw do
  get 'leave_types/resources'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  get '/home', to: 'home#home'
  resources :leaves
  get '/user_leaves/new', to: 'user_leaves#new'
  post '/user_leaves/create', to: 'user_leaves#create'
  # get '/applied_leaves/new', to: 'applied_leaves#new'
  # post '/applied_leaves/create', to: 'applied_leaves#create'
  resources :applied_leaves
end
