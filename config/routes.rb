# frozen_string_literal: true

require_relative 'initializers/subdomain_validator'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :search do
    collection do
      get "get_search_data"
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
    resources :departments do
      member do
        get 'fetch_designations'
      end
    end
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
    resources :settings, only: %i[update] do
      collection do
        get '/', to: 'settings#settings'
      end
    end
  end
end
