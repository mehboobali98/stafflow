Rails.application.routes.draw do
  get 'leave_types/resources'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  get '/home', to: 'home#home'
  resources :leaves
  get '/user_leaves/new', to: 'user_leaves#new'
  post '/user_leaves/create', to: 'user_leaves#create'
  resources :applied_leaves do
    collection do
      get 'show_applied_leaves', as: 'show'
      post 'approve_multiple_leaves', as: 'approve_multiple'
    end
    member do
      patch 'approve_leave', as: 'approve'
      patch 'reject_leave', as: 'reject'
    end
  end
end
