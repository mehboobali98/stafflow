# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
<<<<<<< HEAD
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :benefits
  resources :members, controller: 'users' do
    resources :payrolls, :users_benefits
  end
  scope :admin do
    resources :users
    constraints(SubdomainValidator) do
      root to: 'home#index'
      get '/home', to: 'home#home'
    end
  end
end
=======
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
    registrations: 'users/registrations'
  }
  resources :home do
    collection do
      get :display_companies
    end
  end

  constraints subdomain: /^(?!www\Z)(\w+)/ do
    resources :members, controller: 'users'
  end
end
>>>>>>> 25c25fc82487e45b9a5f9aed0a27677729b06065
