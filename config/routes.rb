Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'dashboard', to: "pages#dashboard"

  get  "simulations", to: "simulations#index"
  post  "sym", to: "simulations#sym"
  get  "asym", to: "simulations#asym"

  resources :simulations, only: [:show, :destroy]
  get "simulations/:id", to: "simulations#show"
  delete "simulations/:id", to: "simulations#destroy"

  get "simulation/:simulation_id/results", to: "results#show", as: 'results_show'
  get "simulation/:simulation_id/resultsbm", to: "results#showbm", as: 'results_showbm'
  get "bmsecondary", to: "simulations#bmsecondary"

  get "participants", to: "agents#participants"
  get "agents", to: "agents#index"

  get "casestudies", to: "study_cases#show"


  post "import", to: "agents#import"
  post "importbm", to: "agents#importbm"
  post "importsecneed", to: "agents#importsecneed"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
