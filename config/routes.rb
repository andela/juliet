Rails.application.routes.draw do
  root "users#new"
  get '/thank-you', :to => 'users#show'
  resources :users, only: [:show, :create]
  resources :media_contents, only: [:create]
end
