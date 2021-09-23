# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members, controller: 'users' do
    resources :user_leaves, except: :create do
      collection do
        post 'mass_create'
      end
    end
    resources :applied_leaves, except: :show
  end
  resources :leaves

  resources :applied_leaves, only: [] do
    collection do
      get 'all_applied_leaves', as: 'all'
      get 'filter_applied_leaves', as: 'filter'
      patch 'approve_leaves', as: 'approve'
      patch 'reject_leaves', as: 'reject'
    end
    member do
      patch 'approve_leave', as: 'approve'
      patch 'reject_leave', as: 'reject'
    end
  end

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
    resources :benefits, except: :show
    resources :members, controller: 'users' do
      resources :payrolls
      resources :users_benefits, except: %i[create show] do
        post 'mass_create'
      end
    end
    resources :departments
    resources :designations
    resources :events do
      collection do
        get 'display_calendar'
      end
    end
  end
end
