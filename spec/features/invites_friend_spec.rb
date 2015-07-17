require 'spec_helper'

feature "User invited friend" do
  scenario "User succesfully invites friend and invitation is accepted", { js: true, vcr: true }  do
    jam = Fabricate(:user)
    sign_in(jam)

    invite_a_friend
    friend_accepts_invitation
    friend_signs_in

    friend_should_follow(jam)
    inviter_should_follow_friend(jam)

    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    fill_in "Friend's Name", with: 'Amber Howard'
    fill_in "Friend's Email Address", with: 'amberhoward1@gmail.com'
    fill_in "Message", with: "Hey girl, you gotta check this out!"
    click_button "Send Invitation"
    sign_out
  end

  def friend_accepts_invitation
    open_email "amberhoward1@gmail.com"
    current_email.click_link "Accept this invitation"

    fill_in "Password", with: "password"
    fill_in "Full Name", with: "Amber Howard"
    fill_in "Credit Card Number", with: "4242424242424242"
    fill_in "Security Code", with: "123"
    select "12 - December", from: "date_month"
    select "2017", from: "date_year"
    click_button "Sign Up"
    expect(page).to have_css('.alert')
  end

  def friend_signs_in
    fill_in "Email Address", with: 'amberhoward1@gmail.com'
    fill_in "Password", with: 'password'
    click_button "Sign in"
  end

  def friend_should_follow(inviter)
    click_link "People"
    expect(page).to have_content inviter.full_name
    sign_out
  end

  def inviter_should_follow_friend(inviter)
    sign_in(inviter)
    click_link "People"
    expect(page).to have_content "Amber Howard"
  end

end
