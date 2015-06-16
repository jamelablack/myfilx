require 'spec_helper'

describe PasswordResetsController do
  describe "GET show" do
    context "if token is valid" do
      it "renders show template" do
        alice = Fabricate(:user)
        alice.update_column(:token, '12345')
        get :show, id: '12345'
        expect(response).to render_template :show
      end

      it "sets @token" do
        alice = Fabricate(:user)
        alice.update_column(:token, '12345')
        get :show, id: '12345'
        expect(assigns(:token)).to eq('12345')
      end
    end
    context "if token in invalid" do
      it "redirects to the expired token page if the token is not valid" do
        get :show, id: '12345'
        expect(response).to redirect_to expired_token_path
      end
    end
  end

  describe "POST create" do

    let(:password_reset) { double 'password reset' }

    context "with valid token" do
      it "redirects to the sign in page" do
        alice = Fabricate(:user)
        alice.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(response).to redirect_to sign_in_path
      end

      it "invokes a PasswordReset" do
        alice = Fabricate(:user)
        alice.update_column(:token, '12345')

        expect(PasswordReset).to receive(:new)
          .with(alice, 'new_password') { password_reset }
        expect(password_reset).to receive(:call)

        post :create, token: '12345', password: 'new_password'
      end

      it "sets the flash success message" do
        alice = Fabricate(:user)
        alice.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(flash[:success]).to be_present
      end

    end

    context "with invalid token" do
      it "redirects to the expired token path" do
        post :create, token: '12345', password: 'some_password'
        expect(response).to redirect_to expired_token_path
      end
    end
  end

end
