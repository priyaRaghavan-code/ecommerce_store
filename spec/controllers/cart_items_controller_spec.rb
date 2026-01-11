require "rails_helper"

RSpec.describe CartItemsController, type: :controller do
  let(:redis) { instance_double(Redis) }

  before do
    allow(controller).to receive(:redis).and_return(redis)
    allow(controller).to receive(:cart_key).and_return("cart:user-1")
  end

  describe "POST #create" do
    it "increments product quantity in redis cart" do
      expect(redis).to receive(:hincrby)
        .with("cart:user-1", "p1", 1)

      post :create, params: { product_id: "p1" }
    end

    it "redirects to home page" do
      allow(redis).to receive(:hincrby)

      post :create, params: { product_id: "p1" }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE #destroy" do
    it "removes product from redis cart" do
      expect(redis).to receive(:hdel)
        .with("cart:user-1", "p1")

      delete :destroy, params: { id: "p1" }
    end

    it "redirects to home page" do
      allow(redis).to receive(:hdel)

      delete :destroy, params: { id: "p1" }

      expect(response).to redirect_to(root_path)
    end
  end
end
