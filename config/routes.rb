Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :events do
    collection do
      get 'display_calendar'
    end
  end
  root to: 'home#index'
  get '/home', to: 'home#home'
end
