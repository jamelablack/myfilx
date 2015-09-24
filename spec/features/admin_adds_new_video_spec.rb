require 'spec_helper'

feature 'Admin Adds New Video', vcr: true do
  scenario 'Admin successfully adds a new video' do
    admin = Fabricate(:admin)
    comedy = Fabricate(:category, name: "Comedy")
    sign_in(admin)
    visit new_admin_video_path

    fill_in "Title", with: "Girls"
    select "Comedy", from: "Category"
    fill_in "Description", with: "What happens in Vegas..."
    attach_file "Large cover", "spec/support/uploads/girls.jpg"
    attach_file "Small cover", "spec/support/uploads/girls.jpg"
    fill_in "Video URL", with: "https://youtu.be/oMK8PbjPwhA"
    click_button "Add Video"

    sign_out
    sign_in

    visit video_path(Video.first)
    expect(page).to have_selector("img[src='/uploads/large_version_girls.jpg']")
    expect(page).to have_selector("a[href='https://youtu.be/oMK8PbjPwhA']")
  end
end
