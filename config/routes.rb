# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  get 'leave_types/resources'
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members, controller: 'users'
  root to: 'home#index'
  get '/home', to: 'home#home'
  resources :leaves
  get '/user_leaves/new', to: 'user_leaves#new'
  post '/user_leaves/create', to: 'user_leaves#create'
  resources :applied_leaves do
    collection do
      get 'show_applied_leaves', as: 'show'
      patch 'approve_multiple_leaves', as: 'approve_multiple'
      patch 'reject_multiple_leaves', as: 'reject_multiple'
    end
    member do
      patch 'approve_leave', as: 'approve'
      patch 'reject_leave', as: 'reject'
    end
  end
end
