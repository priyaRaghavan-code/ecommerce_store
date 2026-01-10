class CouponService
  DISCOUNT_PERCENT = 10

  def initialize(redis)
    @redis = redis
  end

  def config
    cfg = @redis.hgetall("coupon:config")
    {
      nth_order: (cfg["nth_order"] || 5).to_i,
      code: cfg["code"] || "SAVE0510"
    }
  end

  def generate_coupon
    config[:code]
  end

  def discount_amount(total)
    (total.to_i * DISCOUNT_PERCENT) / 100
  end
end
