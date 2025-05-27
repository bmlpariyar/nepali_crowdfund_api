Rails.application.routes.draw do
  get "donations/create"
  get "sessions/create"
  get "users/create"
  get "users/profile"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [:create]
  resources :campaigns, only: [:index, :show, :create, :update, :destroy] do
    resources :donations, only: [:create]
  end
  resources :categories, only: [:index]
  resource :profile, only: [:show, :update], controller: :user_profiles

  #--auth Routes
  post "/login", to: "sessions#create"
  get "/me", to: "users#profile"
  post "/create_user", to: "users#create", as: :create_user
end
