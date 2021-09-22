# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :notifications, only: %i[index] do
    collection do
      post 'mark_as_read'
      get 'count'
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
    get '/dashboard', action: :dashboard, controller: 'dashboard'
    get '/analytics', action: :analytics, controller: 'analytics'
    resources :dashboard, only: [] do
      collection do
        get 'total_events'
        get 'employees_per_department'
        get 'employees_per_city'
      end
    end

    resources :analytics, only: [] do
      collection do
        get 'employee_gender_distribution'
        get 'monthly_payroll'
      end
    end
  end
end
