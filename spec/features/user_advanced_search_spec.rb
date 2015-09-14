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

  context "with title, description, and reviews" do
    it "returns an empty array for no match with reviews option" do
      home_alone = Fabricate(:video, title: "Home Alone")
      love_actually = Fabricate(:video, title: "love Actually")
      home_alone_review = Fabricate(:review, video: "Home Alone", body: "Such a classic")
      refresh_index

      expect(Video.search{"no match", reviews: true).records.to_a).to eq([])
    end
  end

  it "returns an arrayof many videos with relevance title > description > review" do
    mean_girls = Fabricate(:video, title: "Mean Girls")
    double_trouble = Fabricate(:video, title: "Girls with be girls")
    the_notebook = Fabricate(:video, title: "The Notebook")
    the_notebook_review = Fabricate(:review, video: "THe Notebook", body: "Such a girls classic")
      refresh_index

      expect(Video.search("girls", reviews: true).records.to_a).to eq([mean_girls, double_trouble,the_notebook])
  end

  def refresh_index
    Video.import
    Video.__elasticsearch__.refresh_index!
  end
end
