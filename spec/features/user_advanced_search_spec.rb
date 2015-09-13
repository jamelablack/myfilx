require 'spec_helper'

feature "User interacts with advanced search", :elasticsearch do
  background do
    Fabricate(:video, title: "Home Alone")
    Fabricate(:video, title: "Home Alone 2: Kevin is alone in NYC")
    Fabricate(:vidoe, title: "Home is Where the Heart is")
    Fabricate(:video, title: "Love Actually", description: "Love and the holidays")

    refersh_index
    sign_in
    click_on "Advanced Search"
  end

  scenario "user searches with title" do
    within(".advanced_search") do
      fill_in "query" with: "Home Alone"
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

    expect(page).to have_content("Love Acutally")
    expect(page).to have_no_content("Home")
  end

  def refresh_index
    Video.import
    Video.__elasticsearch__.refresh_index
  end

  background do
    home_alone = Fabricate(:video, title: "Hame Alone 1")
    home_alone_2 = Fabricate(:video, title: "Home Alone 2")
    love_actually = Fabricate(:video, title: "Love Actually")
    Fabricate(:video, title: "A Christmas Story", description: "An all-American classic")

    Fabricate(:review, video: home_alone, rating: 5, body: "I love this movie")
    Fabricate(:review, video: home_alone_2, rating: 4)
    Fabricate(:review, video: love_actually, rating: 3)
    Fabricate(:review, video: love_actually, rating: 4)

    refresh index
    sign_in

    click_on "Advanced Search"

  end

  scenario "user searches with title, descripiton, and review" do
    within(".advanced_search") do
      fill_in "query", with "I love this movie"
      check "Include Reviews"
      click_button "Search"
    end
    expect(page).to have_content "Home Alone 1"
    expect(page).to have_content "Home Alone 2"
  end

  scenario "user filters search results with average rating" do
    within (".advanced_search") do
      fill_in "query", with "Star"
      check "Include Reviews"
      select "4.4", from: "rating_from"
      select "4.6", from: "rating_to"

      click_button "Search"
    end

    expect(page).to have_content "Love Actually"
    expect(page).to have_no_content "Home Alone 1"
    expect(page).to have_no_content "Home Alone 2"
  end
end
