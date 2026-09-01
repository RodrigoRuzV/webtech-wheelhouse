Rails.application.routes.draw do
  root "pages#home"

  get "services", to: "pages#services", as: :services
  get "visiting-the-workshop", to: "pages#visiting", as: :visiting
  get "about", to: "pages#about", as: :about
end
