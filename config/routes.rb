require 'sidekiq/web'

Rails.application.routes.draw do

  resources :posts

  root 'posts#index'

  mount Sidekiq::Web => '/sidekiq'

end
