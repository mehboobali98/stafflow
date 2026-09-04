# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # The component previews. Outside the subdomain constraints below on purpose:
  # the design system belongs to no tenant, and mounting it inside them would
  # make it unreachable on the apex host.
  mount Lookbook::Engine, at: '/lookbook' if Rails.env.development?

  root to: 'home#index'
  resources :search, only: [] do
    collection do
      get 'search_data'
    end
  end
  devise_scope :user do
    get 'users', to: 'users/registrations#new'
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
    resources :departments do
      member do
        get 'fetch_designations'
      end
    end
    resources :benefits, except: :show

    resources :members, controller: 'users' do
      collection do
        get :edit_password, to: 'users#edit_password'
        post :update_password, to: 'users#update_password'
      end
      resources :payrolls
      resources :users_benefits, except: %i[create show new] do
        collection do
          post 'mass_create'
          get 'available_benefits'
        end
      end
    end
    resources :departments
    resources :designations
    resources :events do
      collection do
        get 'display_calendar'
      end
    end

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

    get '/dashboard', action: :dashboard, controller: 'dashboard'
    get '/analytics', action: :analytics, controller: 'analytics'

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
        patch 'approve_leaves', as: 'approve'
        patch 'reject_leaves', as: 'reject'
        get 'new_applied_leave_by_hr'
        post 'create_applied_leave_by_hr'
        get 'search_users'
        get 'get_available_user_leaves'
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
    resources :settings, only: %i[update] do
      collection do
        get '/', to: 'settings#settings'
      end
    end

    match '/500', to: 'errors#internal_server_error', via: :all
    match '/404', to: 'errors#not_found', via: :all
    match '/401', to: 'errors#unauthorized', via: :all
    match '/403', to: 'errors#forbidden', via: :all
  end
end
