require "rails_helper"

RSpec.describe CheckoutsController, type: :controller do
  let(:redis) { instance_double(Redis) }

  before do
    allow(controller).to receive(:redis).and_return(redis)
  end

  describe "POST #create" do
    context "when cart is empty" do
      before do
        allow(controller).to receive(:fetch_cart_items!).and_return(nil)
      end

      it "does not redirect" do
        post :create

        expect(response).not_to be_redirect
      end
    end

    context "when cart has items" do
      let(:cart_items) { { "p1" => "2" } }

      before do
        allow(controller).to receive(:fetch_cart_items!).and_return(cart_items)
        allow(controller).to receive(:calculate_subtotal).and_return(200)
        allow(controller).to receive(:next_order_number).and_return(5)
        allow(controller).to receive(:clear_cart)
        allow(controller).to receive(:redirect_to_success)

        allow(redis).to receive(:hincrby)
        allow(redis).to receive(:sadd)
      end

      context "when order is nth order" do
        before do
          allow(controller)
            .to receive(:apply_nth_order_discount)
            .and_return([20, "SAVE0510"])
        end

        it "applies nth order discount logic" do
          post :create

          expect(controller).to have_received(:apply_nth_order_discount)
        end

        it "updates admin data with coupon" do
          expect(controller)
            .to receive(:update_admin_data)
            .with(cart_items, 200, 20, "SAVE0510")

          post :create
        end

        it "clears the cart" do
          post :create

          expect(controller).to have_received(:clear_cart)
        end

        it "redirects to success page" do
          post :create

          expect(controller).to have_received(:redirect_to_success)
        end
      end

      context "when order is not nth order" do
        before do
          allow(controller)
            .to receive(:apply_nth_order_discount)
            .and_return([0, nil])
        end

        it "updates admin data without coupon" do
          expect(controller)
            .to receive(:update_admin_data)
            .with(cart_items, 200, 0, nil)

          post :create
        end

        it "clears the cart" do
          post :create

          expect(controller).to have_received(:clear_cart)
        end
      end
    end
  end

  describe "GET #success" do
    it "renders success page" do
      get :success, params: {
        total: 100,
        discount: 10,
        order_count: 5,
        coupon: "SAVE0510"
      }

      expect(response).to have_http_status(:ok)
    end
  end
end
