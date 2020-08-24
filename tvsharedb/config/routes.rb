Rails.application.routes.draw do
  namespace :admin do
    get 'matching', to: 'matching#index'
    get 'matching/shows'
    get 'matching/possible_matches'
    post 'matching/slack'
    post 'matching/random'
    get 'matching/random'
    put 'matching/match'
  end

  namespace :shows do
    resource :originals do
      get '/', to: 'originals#index'
      get '/:network', to: 'originals#show', as: :network
    end

    resource :genres do
      get '/', to: 'genres#index'
      get '/:genre', to: 'genres#show', as: :genre
    end
  end

  resources :sub_comments
  resources :recommendations
  resources :ratings
  resources :quality_ratings
  resources :preferred_images
  resources :keywords
  resources :crews
  resources :casts
  resources :awards
  resources :shows
  resources :likes
  resources :comments
  post '/auth/login', to: 'authentication#login'
  get '/auth/verify', to: 'authentication#verify'
  post '/genres', to: 'shows#stealing_info'
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
