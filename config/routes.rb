Rails.application.routes.draw do
  devise_for :users
root "catalog#index"
  get "catalog/index"
  get "catalog/show"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  get 'catalog', to: 'catalog#index', as: :catalog
  get 'catalog/:id', to: 'catalog#show', as: :catalog_product
  get 'orders', to: 'orders#index', as: :orders
resource :order, only: [:show] do
  post 'add_item/:product_id', to: 'orders#add_item', as: :add_item
  delete 'remove_item/:product_id', to: 'orders#remove_item', as: :remove_item
  post 'confirm', to: 'orders#confirm', as: :confirm
end


end
