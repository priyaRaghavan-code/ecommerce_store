require "rails_helper"

RSpec.describe Admin::CouponsController, type: :controller do
  let(:redis) { instance_double(Redis) }

  before do
    allow(controller).to receive(:redis).and_return(redis)
  end

  describe "POST #create" do
    context "when admin key is missing or invalid" do
      it "returns unauthorized" do
        request.headers["X-ADMIN-KEY"] = "wrong-key"

        post :create, params: { nth_order: 3, code: "SAVE10" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when admin key is valid" do
      before do
        request.headers["X-ADMIN-KEY"] = "secret"
      end

      it "stores custom coupon configuration in redis" do
        expect(redis).to receive(:hmset).with(
          "coupon:config",
          "nth_order", "3",
          "code", "SAVE10"
        )

        post :create, params: { nth_order: 3, code: "SAVE10" }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Coupon configuration saved")
      end

      it "uses default values when params are missing" do
        expect(redis).to receive(:hmset).with(
          "coupon:config",
          "nth_order", 5,
          "code", "SAVE0510"
        )

        post :create

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Coupon configuration saved")
      end
    end
  end
end
