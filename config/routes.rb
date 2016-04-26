Rails.application.routes.draw do
  root "users#new"
  get '/thank_you' => "users#show", as: :thank_you
  resources :users, only: [:create]
  resources :media_contents, only: [:create]
end
