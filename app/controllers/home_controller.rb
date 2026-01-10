class HomeController < ApplicationController
  def index
    @products = ProductCatalog.all
    @cart = redis.hgetall(cart_key)
  end

  private

  def cart_key
    "cart:#{@user_id}"
  end
end
