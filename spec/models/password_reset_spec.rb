  require "spec_helper"

describe PasswordReset do

  let(:user) { double 'user' }
  let(:reset) { described_class.new(user, 'new_password') }

  before do
    allow(user).to receive(:password=)
    allow(user).to receive(:generate_token)
    allow(user).to receive(:save)
  end

  it "initializes with arguments" do
    expect(reset.user).to eql user
    expect(reset.password).to eql 'new_password'
  end

  describe "#call" do
    it "sets a new password on its user" do
      expect(user).to receive(:password=).with('new_password')
      reset.call
    end

    it "generates a token for its user" do
      expect(user).to receive(:generate_token)
      reset.call
    end

    it "saves its user" do
      expect(user).to receive(:save)
      reset.call
    end
  end

end
