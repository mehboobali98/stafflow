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
end
