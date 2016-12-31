Rails.application.routes.draw do

  resources :users do
    member do
      get :following, :followers  #使用member方法，对应的url地址包含用户的ID
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :microposts, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]

  #get 'static_pages/home'

  #get 'static_pages/help'
  get '/help', to: 'static_pages#help'
  
  get '/about', to: 'static_pages#about'
  
  get '/contact', to: 'static_pages#contact'

  get '/signup', to: 'users#new'

  post '/signup', to: 'users#create'
  
  get '/login', to: 'sessions#new'

  post '/login', to: 'sessions#create'

  delete '/logout', to: 'sessions#destroy'

  root 'static_pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
