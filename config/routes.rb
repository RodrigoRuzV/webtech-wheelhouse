Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Lab 8: every resource answers the seven RESTful actions. repair_jobs has
  # no routes of its own — its rows are written through the repair's form.
  resources :customers
  resources :bikes
  resources :repairs
  resources :services
  resources :staff_members

  get "visiting-the-workshop", to: "pages#visiting", as: :visiting
  get "about", to: "pages#about", as: :about
end
