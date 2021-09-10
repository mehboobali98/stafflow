# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members, controller: 'users' do
    collection do
      get :user_filters, as: :filtered
    end
  end
  get 'users/user_filters', to: 'users#user_filters'
  # constraints(subdomain: '7vas') do
  #   get '/home', to: 'home#home'
  # end
end
