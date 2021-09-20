# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members, controller: 'users' do
    resources :user_leaves
    resources :applied_leaves, except: :show
  end
  resources :leaves

  resources :applied_leaves, except: %i[show index new create edit update destroy] do
    collection do
      get 'show_applied_leaves', as: 'show'
      get 'filter_applied_leaves', as: 'filter'
      post 'add_user_leave'
      get 'show_users_list'
      get 'get_user_leaves'
      get 'get_users_list'
      patch 'approve_multiple_leaves', as: 'approve_multiple'
      patch 'reject_multiple_leaves', as: 'reject_multiple'
    end
    member do
      patch 'approve_leave', as: 'approve'
      patch 'reject_leave', as: 'reject'
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
