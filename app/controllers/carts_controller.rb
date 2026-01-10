class CartsController < ApplicationController
  def show
    @cart_items = redis.hgetall(cart_key)
    @products = ProductCatalog.all.index_by { |p| p[:id] }

    @line_items = build_line_items
    @total_amount = @line_items.sum { |item| item[:line_total] }
  end

  private

  def cart_key
    "cart:#{@user_id}"
  end

  def build_line_items
    @cart_items.map do |product_id, quantity|
      product = @products[product_id]

      {
        product_id: product_id,
        name: product[:name],
        price: product[:price],
        quantity: quantity.to_i,
        line_total: product[:price] * quantity.to_i
      }
    end
  end
end
