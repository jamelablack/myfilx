require 'spec_helper'

feature "User registers", {js: true, vcr: true} do
  scenario "with valid user info and valid card" do
    visit register_path
    fill_in_valid_user_info
    fill_in_credit_card_info('4242424242424242')
    click_button "Sign Up"

    expect(page).to have_content("Thank you for joining for MyFlix! Please sign in now.")
  end
  scenario "with valid user info and invalid card" do
    visit register_path
    fill_in_valid_user_info
    fill_in_credit_card_info('12234')
    click_button "Sign Up"
    expect(page).to have_content("This card number looks invalid.")
  end
  scenario "with valid user info and declined card" do
    visit register_path
    fill_in_valid_user_info
    fill_in_credit_card_info('4000000000000002')
    click_button "Sign Up"
    expect(page).to have_content("Your card was declined.")
  end

  scenario "with invalid user info and valid card" do
    visit register_path
    fill_in_invalid_user_info
    fill_in_credit_card_info('4242424242424242')
    click_button "Sign Up"
    expect(page).to have_content("Your user info is invalid. Please see errors below.")
  end

  scenario "with invalid user info and invalid card" do
    visit register_path
    fill_in_invalid_user_info
    fill_in_credit_card_info('12234')
    wait_for_ajax
    click_button "Sign Up"
    sleep 5
    save_and_open_page
    expect(page).to have_content("This card number looks invalid.")
  end

  scenario "with invalid user info and decinded card" do
    visit register_path
    fill_in_invalid_user_info
    fill_in_credit_card_info('4000000000000002')
    click_button "Sign Up"
    expect(page).to have_content("Your user info is invalid. Please see errors below.")
  end

  def fill_in_valid_user_info
    fill_in "Email Address", with: "jam@jamblack.com"
    fill_in "Password", with: "12345"
    fill_in "Full Name", with: "Jam Black"
  end

  def fill_in_invalid_user_info
    fill_in "Email Address", with: "jam@jamblack.com"
  end

  def fill_in_credit_card_info(credit_card)
    fill_in "Credit Card Number", with: credit_card
    fill_in "Security Code", with: "123"
    select "7 - July", from: "date_month"
    select "2019", from: "date_year"
  end

end
