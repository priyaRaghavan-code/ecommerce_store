class CheckoutsController < ApplicationController
  include CartConcern

  def create
    cart_items = fetch_cart_items!
    return unless cart_items

    subtotal = calculate_subtotal(cart_items)
    order_no = next_order_number

    discount, coupon = apply_nth_order_discount(order_no, subtotal)
    total = subtotal - discount

    update_admin_data(cart_items, subtotal, discount, coupon)
    clear_cart

    redirect_to_success(total, discount, order_no, coupon)
  end

  def success
    @total_paid  = params[:total].to_i
    @discount    = params[:discount].to_i
    @order_count = params[:order_count].to_i
    @coupon_code = params[:coupon]
  end

  private

  def next_order_number
    redis.incr("orders:count")
  end

  def apply_nth_order_discount(order_no, subtotal)
    service = CouponService.new(redis)
    config  = service.config

    return [0, nil] unless order_no % config[:nth_order] == 0

    coupon   = service.generate_coupon
    discount = service.discount_amount(subtotal)

    [discount, coupon]
  end

  def update_admin_data(cart_items, subtotal, discount, coupon)
    redis.hincrby(
      "admin:metrics",
      "total_items_purchased",
      cart_items.values.map(&:to_i).sum
    )

    redis.hincrby(
      "admin:metrics",
      "total_purchase_amount",
      subtotal
    )

    redis.hincrby(
      "admin:metrics",
      "total_discount_amount",
      discount
    )

    redis.sadd("admin:coupons", coupon) if coupon
  end

  def redirect_to_success(total, discount, order_no, coupon)
    redirect_to checkout_success_path(
      total: total,
      discount: discount,
      order_count: order_no,
      coupon: coupon
    )
  end


end
