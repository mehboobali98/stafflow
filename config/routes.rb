# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  resources :departments
  resources :designations

  devise_for :users
  constraints(SubdomainValidator) do
    root to: 'home#index'
    get '/home', to: 'home#home'
  end
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members, controller: 'users'

  # constraints(subdomain: '7vas') do
  #   get '/home', to: 'home#home'
  # end
end
