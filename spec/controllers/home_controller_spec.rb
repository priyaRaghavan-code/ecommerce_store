require "rails_helper"

RSpec.describe HomeController, type: :controller do
  let(:redis) { instance_double(Redis) }

  before do
    allow(controller).to receive(:redis).and_return(redis)
    allow(controller).to receive(:cart_key).and_return("cart:user-1")

    allow(ProductCatalog).to receive(:all).and_return(
      [
        { id: "p1", name: "Product 1", price: 100 },
        { id: "p2", name: "Product 2", price: 200 }
      ]
    )

    allow(redis).to receive(:hgetall)
      .with("cart:user-1")
      .and_return({ "p1" => "2" })
  end

  describe "GET #index" do
    it "returns success response" do
      get :index

      expect(response).to have_http_status(:ok)
    end

    it "loads products from ProductCatalog" do
      get :index

      expect(ProductCatalog).to have_received(:all)
    end

    it "reads cart data from redis" do
      get :index

      expect(redis).to have_received(:hgetall).with("cart:user-1")
    end
  end
end
