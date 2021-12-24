Rails.application.routes.draw do
  get 'pawnrails/console'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'games#index'

  resources :users, only: %i[index]
  resources :games, only: %i[index show create] do
    post 'concede'
    post 'request_draw'
  end
  resources :pieces, only: %i[edit] do
    post 'pawn', to: 'pieces#update_pawn', as: 'update_pawn'
    post 'knight', to: 'pieces#update_knight', as: 'update_knight'
    post 'rook', to: 'pieces#update_rook', as: 'update_rook'
    post 'bishop', to: 'pieces#update_bishop', as: 'update_bishop'
    post 'queen', to: 'pieces#update_queen', as: 'update_queen'
    post 'king', to: 'pieces#update_king', as: 'update_king'
  end
end
