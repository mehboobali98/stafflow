# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  constraints(SubdomainValidator) do
    root to: 'home#index'
    get '/home', to: 'home#home'
  end
end
