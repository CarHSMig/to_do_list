Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, path: "",
              path_names: { sign_in: "login", sign_out: "logout" },
              controllers: { sessions: "sessions", passwords: "passwords" },
              defaults: { format: :json },
              skip: [ :passwords ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.


  # Defines the root path route ("/")
  # root "posts#index"
end
