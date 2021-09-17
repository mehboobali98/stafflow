# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/dashboard', action: :dashboard, controller: 'home'
  resources :settings, only: %i[update] do
    collection do
      get '/', to: 'settings#settings'
    end
  end
  resources :events do
    collection do
      get 'display_calendar'
    end
  end

  resources :members, controller: 'users'
  devise_for :users, controllers: { registrations: 'users/registrations' }
end
