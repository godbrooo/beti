Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :games, only: [ :new, :create, :show, :index ]

  resources :bets, only: [:show, :index]

  get 'games/:id/invite', to: 'games#invite', as: :invite
  post 'games/:id/invite', to: 'games#save_invite'

  get 'games/:id/winners', to: 'games#winners', as: :winners
  patch 'games/:id/winners', to: 'games#close'

  get 'games/:id/resume_', to: 'games#resume_challenge', as: :resume

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?


end
