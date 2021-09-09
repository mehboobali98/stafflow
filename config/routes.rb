# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  #devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  constraints subdomain: /''|www/ do
 as :user do
    get '/', to: 'devise/sessions#new'
    resources :home
  end
  end

  constraints subdomain: /^(?!www\Z)(\w+)/ do
  devise_for :users, :controllers => {
    :sessions => "users/sessions",
    :registrations => "users/registrations",
  }
  as :user do
    get '/', to: 'devise/sessions#new'
  end

    get '/home', to: 'home#home'
    resources :settings, only: %i[update index]
    resources :members, controller: 'users'
  end
end
