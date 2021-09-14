# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  constraints(SubdomainValidator) do
    resources :members, controller: 'users'
    resources :departments
    resources :designations
  end
end
