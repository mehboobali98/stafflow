# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  constraints subdomain: /^(?!www\Z)(\w+)/ do
    resources :settings, only: %i[update] do
      collection do
        get '/', to: 'settings#settings'
      end
    end
    resources :members, controller: 'users'
  end

  devise_for :users, controllers: { registrations: 'users/registrations' }
end
