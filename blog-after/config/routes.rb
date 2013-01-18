Blog::Application.routes.draw do
  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"},
                     controllers: {omniauth_callbacks: "omniauth_callbacks"}

  resources :articles

  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications
  
  root to: 'articles#index'
end
