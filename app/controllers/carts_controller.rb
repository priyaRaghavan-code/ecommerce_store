class CartsController < ApplicationController
  def add
    product_id = params[:product_id]
    redis.hincrby(cart_key, product_id, 1)
    redirect_to root_path
  end

  def remove
    product_id = params[:product_id]
    redis.hdel(cart_key, product_id)
    redirect_to root_path
  end

  private

  def cart_key
    "cart:#{@user_id}"
  end
end
