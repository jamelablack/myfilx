require 'spec_helper'

describe "Create payment on successful charge" do
  let(:event_data) do
   {
    "id" => "evt_16PHhlIVfRceAQlJuDYIQEDm",
    "created" => 1437073657,
    "livemode" => false,
    "type" => "charge.succeeded",
    "data" => {
      "object" => {
        "id" => "ch_16PHhlIVfRceAQlJmXskfuoA",
        "object" => "charge",
        "created" => 1437073657,
        "livemode" => false,
        "paid" => true,
        "status" => "succeeded",
        "amount" => 999,
        "currency" => "usd",
        "refunded" => false,
        "source" => {
          "id" => "card_16PHhkIVfRceAQlJpHkexaXM",
          "object" => "card",
          "last4" => "4242",
          "brand" => "Visa",
          "funding" => "credit",
          "exp_month" => 7,
          "exp_year" => 2019,
          "fingerprint" => "pg1CYhCS9T2GnyZJ",
          "country" => "US",
          "name" => nil,
          "address_line1" => nil,
          "address_line2" => nil,
          "address_city" => nil,
          "address_state" => nil,
          "address_zip" => nil,
          "address_country" => nil,
          "cvc_check" => "pass",
          "address_line1_check" => nil,
          "address_zip_check" => nil,
          "tokenization_method" => nil,
          "dynamic_last4" => nil,
          "metadata" => {},
          "customer" => "cus_6cWlFKrlQzXxPl"
        },
        "captured" => true,
        "balance_transaction" => "txn_16PHhlIVfRceAQlJSqFZW3pK",
        "failure_message" => nil,
        "failure_code" => nil,
        "amount_refunded" => 0,
        "customer" => "cus_6cWlFKrlQzXxPl",
        "invoice" => "in_16PHhlIVfRceAQlJXLpZaTNY",
        "description" => nil,
        "dispute" => nil,
        "metadata" => {},
        "statement_descriptor" => nil,
        "fraud_details" => {},
        "receipt_email" => nil,
        "receipt_number" => nil,
        "shipping" => nil,
        "destination" => nil,
        "application_fee" => nil,
        "refunds" => {
          "object" => "list",
          "total_count" => 0,
          "has_more" => false,
          "url" => "/v1/charges/ch_16PHhlIVfRceAQlJmXskfuoA/refunds",
          "data" => []
        }
      }
    },
      "object" => "event",
      "pending_webhooks" => 1,
      "request" => "req_6cWljYVG5vLK4g",
      "api_version" => "2015-07-07"
    }
  end

  it "creates a payment with the webhook from Stripe for a charge succeeded", :vcr do
    post "/stripe_events", event_data
    expect(Payment.count).to eq(1)
  end

  it "creates the payment associated with the user", :vcr do
    alice = Fabricate( :user, customer_token: "cus_6cWlFKrlQzXxPl")
    post "/stripe_events", event_data
    expect(Payment.first.user).to eq(alice)
  end

  it "creates a payment with the amount", :vcr do
    alice = Fabricate( :user, customer_token: "cus_6cWlFKrlQzXxPl")
    post "/stripe_events", event_data
    expect(Payment.first.amount).to eq(999)
  end

  it "creates a payment with reference id", :vcr do
    alice = Fabricate( :user, customer_token: "cus_6cWlFKrlQzXxPl")
    post "/stripe_events", event_data
    expect(Payment.first.reference_id).to eq("ch_16PHhlIVfRceAQlJmXskfuoA")
  end
end
