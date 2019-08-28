Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'dashboard', to: "pages#dashboard"

  get  "simulations", to: "simulations#index"
  post  "sym", to: "simulations#sym"
  post  "asym", to: "simulations#asym"

  resources :simulations, only: [:show, :destroy]
  get "simulations/:id", to: "simulations#show"
  delete "simulations/:id", to: "simulations#destroy"

  get "simulation/:simulation_id/results", to: "results#show", as: 'results_show'
  get "simulation/:simulation_id/resultsbm", to: "results#showbm", as: 'results_showbm'
  get "simulation/:simulation_id/resultsbmter", to: "results#showbmter", as: 'results_showbmter'
  post "bmsecondary", to: "simulations#bmsecondary"
  post "bmterciary", to: "simulations#bmterciary"

  get "participants", to: "agents#participants"
  get "participantsbm", to: "agents#participantsbm"
  get "agents", to: "agents#index"

  get "casestudies", to: "study_cases#show"


  post "import", to: "agents#import"
  post "importbmsec", to: "agents#importbmsec"
  post "importbmter", to: "agents#importbmter"
  post "importsecneed", to: "agents#importsecneed"
  post "importtercneed", to: "agents#importtercneed"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
