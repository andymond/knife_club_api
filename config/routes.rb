Rails.application.routes.draw do
  namespace :v1 do
    resources :users, only: [:create, :show]
    resources :sessions, only: [:create, :destroy]
    post 'password_resets', to: "password_resets#create"
    put 'password_resets', to: "password_resets#update", as: :update_password
    get 'password_resets/edit/:id', to: "password_resets#edit"
  end
end
