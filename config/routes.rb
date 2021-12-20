Rails.application.routes.draw do
  get 'pawnrails/console'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'games#index'

  resources :games
  resources :pieces, only: %i[edit] do
    post 'pawn', to: 'pieces#update_pawn', as: 'update_pawn'
  end
end
