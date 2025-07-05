Rails.application.routes.draw do
  get "ai_assistant/analyze"
  get "recommendations/index"
  get "campaign_views/create"
  get "donations/create"
  get "sessions/create"
  get "users/create"
  get "users/profile"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [:create]
  resources :campaigns, only: [:index, :show, :create, :update, :destroy] do
    resources :donations, only: [:create]
    post "view", to: "campaign_views#create"
  end

  namespace :admin do
    get "users/index"
    get "users/show"
    get "users/update"
    resources :users, only: [:index, :show, :update]
  end

  namespace :api do
    namespace :v1 do

      # Dashboard routes
      namespace :dashboard do
        get "user_count_details", to: "dashboard_api#user_count_details"
        get "get_weekly_campaign_activities", to: "dashboard_api#get_weekly_campaign_activities"
        get "get_category_campaign_details", to: "dashboard_api#get_category_campaign_details"
      end

      # ChatMessages nested under Campaigns
      resources :campaigns do
        resources :chat_messages, only: [:index, :create] do
          collection do
            post :mark_as_read
            get :unread_count
          end
        end
      end
    end
  end

  resources :categories, only: [:index]
  resource :profile, only: [:show, :update], controller: :user_profiles
  resource :recommendations, only: [:index], controller: :recommendations

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
  get "/search", to: "campaigns#search", as: :search

  get "/featured_campaigns", to: "campaigns#featured_campaigns", as: :featured_campaigns
  post "ai_assistant/analyze", to: "ai_assistant#analyze"

  get "/campaigns/:id/estimate_completion_date", to: "campaigns#estimate_completion_date", as: :estimate_completion_date
end
