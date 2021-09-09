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
      get 'display_pending_leaves'
    end
    member do
      post 'approve_leave'
      post 'reject_leave'
    end
  end
end
