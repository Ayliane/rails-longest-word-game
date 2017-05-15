Rails.application.routes.draw do
  get 'game', to: 'pages#game'

  get 'score', to: 'pages#score'

  root to: 'pages#game'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
