Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Lab 8: every resource answers the seven RESTful actions. repair_jobs has
  # no routes of its own — its rows are written through the repair's form.
  resources :customers
  resources :bikes
  resources :repairs do
    # Lab 9: one intake photo is removed on its own (DELETE, never GET).
    resources :photos, only: :destroy, controller: "repair_photos"
  end
  resources :services
  resources :staff_members

  get "visiting-the-workshop", to: "pages#visiting", as: :visiting
  get "about", to: "pages#about", as: :about

  # Lab 10: the JSON API, for programs that are not a browser. The version
  # is a segment of the path, and everything under /api/v1 answers JSON.
  # No new and no edit: a program does not need a form.
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :services, only: %i[index show create]
      resources :repairs, only: %i[index show]
    end
  end
end
