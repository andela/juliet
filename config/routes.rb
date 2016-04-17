Rails.application.routes.draw do
    root "users#index"
    get '/auth/:provider/callback' => "users#create"
    resources :users, only: [:show, :new]
end
