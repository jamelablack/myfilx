require 'spec_helper'

feature 'Admin views payments' do
  background do
    jane = Fabricate(:user, full_name: "Jane Doe", email: "jane@example.com")
    Fabricate(:payment, amount: 999, user: jane)
  end
  scenario "admin can see payments" do
    sign_in(Fabricate(:admin))
    visit admin_payments_path
    expect(page).to have_content("$9.99")
    expect(page).to have_content("Jane Doe")
    expect(page).to have_content("jane@example.com")
  end


  scenario "user cannot see payments" do
  sign_in(Fabricate(:user))
    visit admin_payments_path
    expect(page).not_to have_content("$9.99")
    expect(page).not_to have_content("Jane Doe")
    expect(page).to have_content("You're not authorized to do that.")
  end
end
