Rails.application.routes.draw do
  get "custom_bouquets/new"
  get "custom_bouquets/create"
  namespace :admin do
    get "orders/index"
    get "orders/show"
  end


  get "pages/about"
  get "pages/delivery"
  get "pages/contacts"
get 'about', to: 'pages#about', as: :about
get 'delivery', to: 'pages#delivery', as: :delivery
get 'contacts', to: 'pages#contacts', as: :contacts
  devise_for :users
root to: "pages#home"   # если хочешь, чтобы главная страница была home

# или явно дать имя маршруту:
get 'home', to: 'pages#home', as: 'home'


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
    patch 'update_quantity', on: :collection
  post 'add_item/:product_id', to: 'orders#add_item', as: :add_item
  delete 'remove_item/:product_id', to: 'orders#remove_item', as: :remove_item
  post 'increase_item', to: 'orders#increase_item', as: :increase_item
  post 'decrease_item', to: 'orders#decrease_item', as: :decrease_item
  post 'confirm', to: 'orders#confirm', as: :confirm
  
end
resources :orders do
  member do
    patch :cancel
  end
end

namespace :admin do
  root to: "products#index"
  resources :products
    resources :orders do
    member do
      patch :update_status
    end
  end
end
  resources :order, only: [:update]

resources :custom_bouquets, only: [:new, :create]


end
