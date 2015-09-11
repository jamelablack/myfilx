require 'spec_helper'

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
