# frozen_string_literal: true

Rails.application.routes.draw do
  resources :departments
  resources :designations

  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  get '/home', to: 'home#home'
end
