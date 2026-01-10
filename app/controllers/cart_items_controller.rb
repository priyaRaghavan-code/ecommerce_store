class CartItemsController < ApplicationController
  def create
    redis.hincrby(cart_key, params[:product_id], 1)
    redirect_to root_path
  end

  def destroy
    redis.hdel(cart_key, params[:id])
    redirect_to root_path
  end

  private

  def cart_key
    "cart:#{@user_id}"
  end
end
