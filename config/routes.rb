Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'dashboard', to: "pages#dashboard"

  get  "simulation", to: "simulations#index"
  get "simulation/:simulation_id/results", to: "results#show", as: 'results_show'
  get  "agents", to: "agents#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
