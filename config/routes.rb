Rails.application.routes.draw do
  root "home#index"

  resource :cart, only: [:show] do
    resources :items, only: [:create, :destroy], controller: "cart_items"
  end

  post "/cart/apply_coupon", to: "carts#apply_coupon"
  post "/checkout", to: "checkouts#create"
  get "/checkout/success", to: "checkouts#success"
  namespace :admin do
    get "/dashboard", to: "dashboards#show"
    post "/coupons",   to: "coupons#create"
  end
end
