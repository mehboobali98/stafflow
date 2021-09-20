# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :notifications, only: %i[destroy] do
    collection do
      get '/', to: 'notifications#fetch_user_notifications'
      post '/read', to: 'notifications#mark_as_read'
      get '/count', to: 'notifications#notifications_count'
    end
  end
  as :user do
    root to: 'devise/sessions#new'
  end
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

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }

  resources :home do
    collection do
      get :display_companies
    end
  end
  constraints subdomain: /^(?!www\Z)(\w+)/ do
    resources :members, controller: 'users'
    resources :departments
    resources :designations
    resources :events do
      collection do
        get 'display_calendar'
      end
    end
  end
end
