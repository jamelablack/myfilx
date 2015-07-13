require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    describe ".create" do
      it "makes a succesful charge", :vcr do
        token = Stripe::Token.create(
          :card => {
          :number => 4242424242424242,
          :exp_month => 7,
          :exp_year => 2016,
          :cvc => 390
            }
          ).id

        response = StripeWrapper::Charge.create(
          amount: 999,
          card: token,
          description: "Myflix signup charge"

          )
        expect(response).to be_successful
      end

      it "does not make a successful charge", :vcr do
        token = Stripe::Token.create(
          :card => {
          :number => 4000000000000002,
          :exp_month => 7,
          :exp_year => 2016,
          :cvc => 390
            }
          ).id

        response = StripeWrapper::Charge.create(
          amount: 999,
          card: token,
          description: "Myflix signup charge"

          )
        expect(response).not_to be_successful
      end

      it "returns the error message for declined charges", :vcr do
        token = Stripe::Token.create(
          :card => {
          :number => 4000000000000002,
          :exp_month => 7,
          :exp_year => 2016,
          :cvc => 390
            }
          ).id

        response = StripeWrapper::Charge.create(
          amount: 999,
          card: token,
          description: "Myflix signup charge"

          )
        expect(response.error_message).to eq("Your card was declined.")
      end
    end
  end
end

