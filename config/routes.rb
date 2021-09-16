# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
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
  resources :departments
  resources :designations

  resources :members, controller: 'users'
  devise_for :users, controllers: { registrations: 'users/registrations' }
end
