Rails.application.routes.draw do
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
