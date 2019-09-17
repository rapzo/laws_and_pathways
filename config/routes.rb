Rails.application.routes.draw do
  # TPI
  resources :sectors, only: [:show, :index] do
    collection do
      get :companies_levels
      get :scenarios
    end
    member do
      get :companies_levels
      get :companies_emissions
    end
  end
  resources :companies, only: [:show] do
    member do
      get :emissions
    end
  end

  # development only elements and components list
  get '/sandbox', to: 'sandbox#index' if Rails.env.development?

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: 'admin/dashboard#index'
end
