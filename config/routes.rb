Rails.application.routes.draw do
  root "home#index"

  resource :cart, only: [:show] do
    resources :items, only: [:create, :destroy], controller: "cart_items"
  end
end
