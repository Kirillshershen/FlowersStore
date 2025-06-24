Rails.application.routes.draw do
  get "notifications/index"
  get "notifications/mark_as_read"
namespace :admin do
  resources :users, only: [:index, :edit, :update]
    get 'statistics/sales'
  resources :statistics, only: [:index]
end
  # Маршруты для кастомных букетов
  get "custom_bouquets/new"
  get "custom_bouquets/create"
  resources :custom_bouquets, only: [:new, :create]

  # Telegram webhook
  post '/telegram_webhook', to: 'telegram#webhook'

  # Страницы сайта
  get "pages/about"
  get "pages/delivery"
  get "pages/contacts"
  get 'about', to: 'pages#about', as: :about
  get 'delivery', to: 'pages#delivery', as: :delivery
  get 'contacts', to: 'pages#contacts', as: :contacts

  # Devise маршруты для пользователей
  devise_for :users

  # Главная страница
  root to: "pages#home"   # если хочешь, чтобы главная страница была home
  get 'home', to: 'pages#home', as: 'home'  # альтернативный маршрут с именем

  # Каталог
  get "catalog/index"
  get "catalog/show"
  get 'catalog', to: 'catalog#index', as: :catalog
  get 'catalog/:id', to: 'catalog#show', as: :catalog_product
patch 'orders/update_quantity', to: 'orders#update_quantity'

  # Заказы - разные варианты маршрутов
  get 'orders', to: 'orders#index', as: :orders
patch '/orders/update_quantity', to: 'orders#update_quantity', as: :update_quantity_order
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
      get :details 
    end
  end

  resources :order, only: [:update]

  # Админка
  namespace :admin do
    root to: "products#index"
    get 'sales_statistics', to: 'statistics#sales'
    resources :packagings
    resources :banners
    resources :products
    resources :promotions

    get "orders/index"
    get "orders/show"
    
    resources :orders do
      member do
        patch :update_status
      end
    end
  end
    resources :reviews, only: [:index, :new, :create]
resources :notifications, only: [:index] do
  member do
    patch :mark_as_read
  end
end

  # Статус здоровья приложения
  get "up" => "rails/health#show", as: :rails_health_check

  # Закомментированные (PWA) маршруты для манифеста и service worker
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
