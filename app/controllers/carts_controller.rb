class CartsController < ApplicationController
  def show
    load_cart
    set_discount_eligibility_hint
  end

  private

  def cart_key
    "cart:#{@user_id}"
  end

  def load_cart
    @cart_items = redis.hgetall(cart_key)
    @products = ProductCatalog.all.index_by { |p| p[:id] }

    @line_items = @cart_items.map do |product_id, quantity|
      product = @products[product_id]

      {
        product_id: product_id,
        name: product[:name],
        price: product[:price],
        quantity: quantity.to_i,
        line_total: product[:price] * quantity.to_i
      }
    end

    @subtotal = @line_items.sum { |i| i[:line_total] }.to_i
  end

  def set_discount_eligibility_hint
    current_order_count = redis.get("orders:count").to_i
    nth = CouponService.new(redis).config[:nth_order]

    @eligible_for_discount = ((current_order_count + 1) % nth == 0)
  end
end
