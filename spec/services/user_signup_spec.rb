require 'spec_helper'

describe UserSignup do
  describe "#sign_up" do
    context "with valid personal info and approved card" do
      let(:customer) { double(:customer, successful?: true, customer_token: '1swfsfc41') }
      before { StripeWrapper::Customer.should_receive(:create).and_return(customer) }
      after { ActionMailer::Base.deliveries.clear }

      it "creates the user" do
        UserSignup.new(Fabricate.build(:user)).sign_up("some_stripe_token", nil)
        expect(User.count).to eq(1)
      end

      it "store the customer token from Stripe" do
        UserSignup.new(Fabricate.build(:user)).sign_up("some_stripe_token", nil)
        expect(User.first.customer_token).to eq('1swfsfc41')
      end

      it "makes the user follow the inviter" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'jam@jamblack.com')
        UserSignup.new(Fabricate.build(:user, email: 'jam@jamblack.com', password: 'password', full_name: 'Jam Black')).sign_up("some_stripe_token", invitation.token)
        jam = User.where(email: 'jam@jamblack.com').first
        expect(jam.follows?(alice)).to be_true
      end

      it "makes the inviter follow the user" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'jam@jamblack.com')
        UserSignup.new(Fabricate.build(:user, email: 'jam@jamblack.com', password: 'password', full_name: 'Jam Black')).sign_up("some_stripe_token", invitation.token)
        jam = User.where(email: 'jam@jamblack.com').first
        expect(alice.follows?(jam)).to be_true
      end
      it "expires the invitation upon acceptance" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'jam@jamblack.com')
        UserSignup.new(Fabricate.build(:user, email: 'jam@jamblack.com', password: 'password', full_name: 'Jam Black')).sign_up("some_stripe_token", invitation.token)
        jam = User.where(email: 'jam@jamblack.com').first
        expect(Invitation.first.token).to be_nil
      end

      it "sends out email to the user with valid inputs" do
        UserSignup.new(Fabricate.build(:user, email: 'jam@jamblack.com')).sign_up("some_stripe_token", nil)
        expect(ActionMailer::Base.deliveries.last.to).to eq(['jam@jamblack.com'])
      end

      it "sends out email containing the user's name with valid inputs" do
        UserSignup.new(Fabricate.build(:user, email: 'jam@jamblack.com', password: "password", full_name: "Jamela Black")).sign_up("some_stripe_token", nil)
        expect(ActionMailer::Base.deliveries.last.body).to include("Jamela Black")
      end
    end
    context "valid personal info but declined card" do
      after { ActionMailer::Base.deliveries.clear }
      it "does not create a new user record" do
        customer = double(:customer, successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Customer.should_receive(:create).and_return(customer)
        UserSignup.new(Fabricate.build(:user)).sign_up('1234567', nil)
        expect(User.count).to eq(0)
      end
    end
    context "with invalid personal info" do
      it "does not create the user" do
        UserSignup.new(User.new(email: 'jam@jamblack.com')).sign_up('1234567', nil)
        expect(User.count).to eq(0)
      end

      it "does not charge the card" do
        StripeWrapper::Customer.should_not_receive(:create)
        UserSignup.new(User.new(email: 'jam@jamblack.com')).sign_up('1234567', nil)
      end

      it "does not send out email with invalid inputs" do
        UserSignup.new(User.new(email: 'jam@jamblack.com')).sign_up('1234567', nil)
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
