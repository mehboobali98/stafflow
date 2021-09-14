# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members, controller: 'users'
  resources :notifications, only: %i[destroy] do
    collection do
      get '/', to: 'notifications#fetch_user_notifications'
    end
  end
  get '/notifications_count', to: 'notifications#notifications_count'
  # constraints(subdomain: '7vas') do
  #   get '/home', to: 'home#home'
  # end
end
