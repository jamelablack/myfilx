
require 'sidekiq/web'

Myflix::Application.routes.draw do
	root to: 'pages#front'
	get '/home', to: 'videos#index'
  get 'ui(/:action)', controller: 'ui'
  mount Sidekiq::Web, at: '/sidekiq'

  resources :videos, only: [:show, :index] do
  	collection do
  	 get :search
  	end
    resources :reviews, only: [:create]
  end
  resources :categories, only: [:show]

  namespace :admin do
    resources :videos, only: [:new, :create]
    resources :payments, only: [:index]
  end

  get '/register', to: 'users#new'
  resources :users, only: [:create, :show]
  get 'register/:token', to: "users#new_with_invitation_token", as: 'register_with_token'
  get '/sign_in', to: 'sessions#new'
  get '/sign_out', to: 'sessions#destroy'
  resources :sessions, only: [:create]

  get '/my_queue', to: "queue_items#index"
  resources :queue_items, only: [:create, :destroy]
  post 'update_queue', to: 'queue_items#update_queue'

  get 'people', to: 'relationships#index'
  resources :relationships, only: [:create, :destroy]

  get 'forgot_password', to: 'forgot_passwords#new'
  resource :forgot_passwords, only: [:create]
  get 'forgot_password_confirmation', to: 'forgot_passwords#confirm'

  resources :password_resets, only: [:show, :create]
  get 'expired_token', to: 'pages#expired_token'

  resources :invitations, only: [:new, :create]

  mount StripeEvent::Engine => '/stripe_events'
end
