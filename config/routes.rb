# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  as :user do
    root to: 'devise/sessions#new'
  end
  resources :events do
    collection do
      get 'display_calendar'
    end
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  resources :home do
    collection do
      post :display_companies
    end
  end

  constraints subdomain: /^(?!www\Z)(\w+)/ do
    resources :members, controller: 'users'
  end
end
