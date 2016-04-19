Rails.application.routes.draw do
  root "users#new"
  resources :users, only: [:show, :create]
  resources :media_contents, only: :create
end
