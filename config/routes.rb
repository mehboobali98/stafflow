# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  constraints subdomain: 'abc' do
    devise_for :users

    root to: 'home#index'
    get '/home', to: 'home#home'
    resources :settings, only: %i[create edit new update index show]
    get '/home', to: 'home#home'
  end
end
