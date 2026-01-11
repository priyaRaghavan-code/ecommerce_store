require "rails_helper"

RSpec.describe Admin::DashboardsController, type: :controller do
  let(:redis) { instance_double(Redis) }

  before do
    allow(controller).to receive(:redis).and_return(redis)
  end

  describe "GET #show" do
    context "when admin key is invalid" do
      it "returns unauthorized status" do
        request.headers["X-ADMIN-KEY"] = "wrong-key"

        get :show

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when admin key is valid" do
      before do
        request.headers["X-ADMIN-KEY"] = "secret"

        allow(redis).to receive(:hgetall).with("admin:metrics").and_return(
          {
            "total_items_purchased" => "10",
            "total_purchase_amount" => "50000",
            "total_discount_amount" => "5000"
          }
        )

        allow(redis).to receive(:smembers)
          .with("admin:coupons")
          .and_return(["SAVE0510", "SAVE10"])
      end

      it "returns http success" do
        get :show

        expect(response).to have_http_status(:ok)
      end

      it "returns total_items_purchased" do
        get :show

        expect(JSON.parse(response.body)["total_items_purchased"]).to eq(10)
      end

      it "returns total_purchase_amount" do
        get :show

        expect(JSON.parse(response.body)["total_purchase_amount"]).to eq(50000)
      end

      it "returns total_discount_amount" do
        get :show

        expect(JSON.parse(response.body)["total_discount_amount"]).to eq(5000)
      end

      it "returns discount codes" do
        get :show

        expect(JSON.parse(response.body)["discount_codes"])
          .to eq(["SAVE0510", "SAVE10"])
      end
    end

    context "when redis metrics are empty" do
      before do
        request.headers["X-ADMIN-KEY"] = "secret"

        allow(redis).to receive(:hgetall)
          .with("admin:metrics")
          .and_return({})

        allow(redis).to receive(:smembers)
          .with("admin:coupons")
          .and_return([])
      end

      it "returns zero total_items_purchased" do
        get :show

        expect(JSON.parse(response.body)["total_items_purchased"]).to eq(0)
      end

      it "returns zero total_purchase_amount" do
        get :show

        expect(JSON.parse(response.body)["total_purchase_amount"]).to eq(0)
      end

      it "returns zero total_discount_amount" do
        get :show

        expect(JSON.parse(response.body)["total_discount_amount"]).to eq(0)
      end

      it "returns empty discount_codes" do
        get :show

        expect(JSON.parse(response.body)["discount_codes"]).to eq([])
      end
    end
  end
end
