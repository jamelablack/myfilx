require 'spec_helper'

describe 'Deactivate user on failed charge' do
  let(:event_data) do
  {
    "id" => "evt_16PPkyIVfRceAQlJL9W2HaEt",
    "created" => 1437104608,
    "livemode" => false,
    "type" => "charge.failed",
    "data" => {
      "object" => {
        "id" => "ch_16PPkyIVfRceAQlJmk61Uf95",
        "object" => "charge",
        "created" => 1437104608,
        "livemode" => false,
        "paid" => false,
        "status" => "failed",
        "amount" => 999,
        "currency" => "usd",
        "refunded" => false,
        "source" => {
          "id" => "card_16PPkBIVfRceAQlJ0sZggVlC",
          "object" => "card",
          "last4" => "0341",
          "brand" => "Visa",
          "funding" => "credit",
          "exp_month" => 7,
          "exp_year" => 2018,
          "fingerprint" => "JUUeElejd4oUbH8P",
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
          "customer" => "cus_6cex2bmvunQIYo"
        },
        "captured" => false,
        "balance_transaction" => nil,
        "failure_message" => "Your card was declined.",
        "failure_code" => "card_declined",
        "amount_refunded" => 0,
        "customer" => "cus_6cex2bmvunQIYo",
        "invoice" => nil,
        "description" => "Declined Charge",
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
          "url" => "/v1/charges/ch_16PPkyIVfRceAQlJmk61Uf95/refunds",
          "data" => []
        }
      }
    },
    "object" => "event",
    "pending_webhooks" => 1,
    "request" => "req_6cf5kw6RsHOvQw",
    "api_version" => "2015-07-07"
  }
  end

  it "deactivates a user with the webhook data from stripe for charge failed", :vcr do
    jane = Fabricate(:user, customer_token: "cus_6cex2bmvunQIYo")
    post '/stripe_events', event_data
    expect(jane.reload).not_to be_active
  end
end
