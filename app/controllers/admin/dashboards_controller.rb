module Admin
  class DashboardsController < ApplicationController
    before_action :authorize_admin!

    def show
      metrics = redis.hgetall("admin:metrics")

      render json: {
        total_items_purchased: metrics["total_items_purchased"].to_i,
        total_purchase_amount: metrics["total_purchase_amount"].to_i,
        total_discount_amount: metrics["total_discount_amount"].to_i,
        discount_codes: redis.smembers("admin:coupons")
      }
    end

    private

    def authorize_admin!
      head :unauthorized unless request.headers["X-ADMIN-KEY"] == "secret"
    end
  end
end
