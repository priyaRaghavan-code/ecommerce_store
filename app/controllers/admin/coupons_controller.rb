module Admin
  class CouponsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authorize_admin!

    def create
      redis.hmset(
        "coupon:config",
        "nth_order", params.fetch(:nth_order, 5),
        "code", params.fetch(:code, "SAVE0510")
      )

      render json: { message: "Coupon configuration saved" }
    end

    private

    def authorize_admin!
      head :unauthorized unless request.headers["X-ADMIN-KEY"] == "secret"
    end
  end
end
