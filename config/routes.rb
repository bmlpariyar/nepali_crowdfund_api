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

  get "/campaigns/:campaign_id/support_messages", to: "donations#get_support_messages", as: :get_support_messages
  post "/campaigns/:campaign_id/update_messages", to: "update_messages#create", as: :create_update_message
  get "/campaigns/:campaign_id/get_update_messages", to: "update_messages#get_update_messages", as: :get_update_messages

  get "/campaigns/:campaign_id/all_donations", to: "donations#get_all_donations", as: :get_all_donations
  get "/campaigns/:campaign_id/top_donations", to: "donations#get_top_donations", as: :get_top_donations
  get "/campaigns/:campaign_id/donation_highlight", to: "donations#donation_highlight", as: :donation_highlight
end
