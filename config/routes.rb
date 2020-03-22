Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :v1 do
    resources :users, only: [:create, :show]
    resources :sessions, only: [:create]
    delete "sessions", to: "sessions#destroy"
    post "password_resets", to: "password_resets#create"
    put "password_resets", to: "password_resets#update", as: :update_password
    get "password_resets/edit/:id", to: "password_resets#edit"

    resources :cookbooks, only: %i(create show index update destroy) do
      resources :recipes, only: %i(create show index update destroy)
      resources :sections, only: %i(create update)
    end
  end
end
