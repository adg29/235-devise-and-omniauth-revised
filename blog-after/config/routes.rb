Blog::Application.routes.draw do
  resources :salons


  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"},
                     controllers: {omniauth_callbacks: "omniauth_callbacks",
                     				:registrations => 'registrations'}

  resources :articles

  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications
  
  root to: 'salons#index'
end
