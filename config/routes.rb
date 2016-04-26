Rails.application.routes.draw do
  root "users#new"
  # get '/users/:id', to: 'users#show', as: :thank_you
  resources :users, only: [:create]
  resources :users, :path => '/thank_you', only: [:show], as: :thank_you
  resources :media_contents, only: [:create]
end
