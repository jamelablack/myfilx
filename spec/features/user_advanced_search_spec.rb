require 'spec_helper'

feature "User interacts with advanced search", :elasticsearch do
  background do
    Fabricate(:video, title: "Home Alone")
    Fabricate(:video, title: "Home Alone 2: Kevin is alone in NYC")
    Fabricate(:video, title: "Home is Where the Heart is")
    Fabricate(:video, title: "Love Actually", description: "Love and the holidays")

    refresh_index
    sign_in
    click_on "Advanced Search"
  end

  scenario "user searches with title" do
    within(".advanced_search") do
      fill_in "query", with: "Home Alone"
      click_button "Search"
    end

    expect(page).to have_content("2 videos found")
    expect(page).to have_content("Home Alone")
    expect(page).to have_content("Home Alone 2: Kevin is alone in NYC")
    expect(page).to have_no_content("Home is Where the Heart is")
  end

  scenario "user searches with the title and description" do
    within(".advanced_search") do
      fill_in "query", with: "love and the holidays"
      click_button "Search"
    end

    expect(page).to have_content("Love Actually")
    expect(page).to have_no_content("Home")
  end

  def refresh_index
    Video.import
    Video.__elasticsearch__.refresh_index!
  end
end
