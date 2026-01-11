require "rails_helper"

RSpec.describe CartsController, type: :controller do
  let(:redis) { instance_double(Redis) }

  before do
    allow(controller).to receive(:redis).and_return(redis)
    allow(controller).to receive(:cart_key).and_return("cart:user-1")

    allow(redis).to receive(:hgetall)
      .with("cart:user-1")
      .and_return({ "p1" => "2" })

    allow(redis).to receive(:get)
      .with("orders:count")
      .and_return("4")

    allow(ProductCatalog).to receive(:all).and_return(
      [{ id: "p1", name: "Product 1", price: 100 }]
    )

    coupon_service = instance_double(CouponService)
    allow(CouponService).to receive(:new).and_return(coupon_service)

    allow(coupon_service).to receive(:config)
      .and_return({ nth_order: 5 })

    # ✅ THIS WAS MISSING
    allow(coupon_service).to receive(:discount_amount)
      .with(200)
      .and_return(20)
  end

  describe "GET #show" do
    it "returns success response" do
      get :show
      expect(response).to have_http_status(:ok)
    end

    it "reads cart data from redis" do
      get :show
      expect(redis).to have_received(:hgetall).with("cart:user-1")
    end

    it "checks order count for discount eligibility" do
      get :show
      expect(redis).to have_received(:get).with("orders:count")
    end

    it "loads product catalog" do
      get :show
      expect(ProductCatalog).to have_received(:all)
    end

    it "reads coupon configuration" do
      get :show
      expect(CouponService).to have_received(:new)
    end
  end
end
