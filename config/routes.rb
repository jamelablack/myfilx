Myflix::Application.routes.draw do
	root to: 'pages#front'
	get '/home', to: 'videos#index'
  get 'ui(/:action)', controller: 'ui'

  resources :videos, only: [:show, :index] do
  	collection do
  	 get :search
  	end
    resources :reviews, only: [:create]
  end
  resources :categories, only: [:show]

  get '/register', to: 'users#new'
  resources :users, only: [:create]
  get '/sign_in', to: 'sessions#new'
  get '/sign_out', to: 'sessions#destroy'
  resources :sessions, only: [:create]

  get '/my_queue', to: "queue_items#index"
  resources :queue_items, only: [:create, :destroy]
  post 'update_queue', to: 'queue_items#update_queue'

end
