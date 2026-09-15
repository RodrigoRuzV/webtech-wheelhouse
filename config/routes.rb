Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  resources :customers, only: [ :index, :show ]
  resources :bikes, only: [ :index, :show ]
  resources :repairs, only: [ :index, :show ]
  resources :services, only: [ :index, :show ]
  resources :staff_members, only: [ :index, :show ]

  get "visiting-the-workshop", to: "pages#visiting", as: :visiting
  get "about", to: "pages#about", as: :about
end
