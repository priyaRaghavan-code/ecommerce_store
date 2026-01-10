module CartConcern
  extend ActiveSupport::Concern

  private

  def cart_key
    "cart:#{@user_id}"
  end

  def fetch_cart_items!
    cart_items = redis.hgetall(cart_key)

    if cart_items.empty?
      redirect_to cart_path, alert: "Cart is empty"
      return
    end

    cart_items
  end

  def clear_cart
    redis.del(cart_key)
  end

  def cart_items_count(cart_items)
    cart_items.values.map(&:to_i).sum
  end

  def calculate_subtotal(cart_items)
    products = ProductCatalog.all.index_by { |p| p[:id] }

    cart_items.sum do |product_id, quantity|
      products[product_id][:price] * quantity.to_i
    end
  end
end
