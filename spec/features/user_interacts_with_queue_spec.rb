require 'spec_helper'

feature "User interacts with the queue" do
  scenario "user adds and reorders videos in the queue" do

    comedy = Fabricate(:category)
    broad_city = Fabricate(:video, title: "Broad City", category: comedy)
    girls = Fabricate(:video, title: "Girls", category: comedy)
    satc = Fabricate(:video, title: "Sex and the City", category: comedy)

    sign_in

    add_video_to_queue(broad_city)
    expect_video_to_be_in_queue(broad_city)

    visit video_path(broad_city)
    expect_video_to_not_be_in_queue("+ My Queue")

    add_video_to_queue(girls)
    add_video_to_queue(satc)

    set_video_position(girls, 3)
    set_video_position(satc, 1)
    set_video_position(broad_city, 2)
    update_queue

    expect_video_position(girls, 3)
    expect_video_position(satc, 1)
    expect_video_position(broad_city, 2)
  end

  def expect_video_to_be_in_queue(video)
    page.should have_content(video.title)
  end

  def expect_video_to_not_be_in_queue(link_text)
    page.should_not have_content link_text
  end

  def update_queue
    click_button "Update Instant Queue"
  end

  def add_video_to_queue(video)
    visit home_path
    find("a[href='/videos/#{video.id}']").click
    click_link "+ My Queue"
  end

  def set_video_position(video, position)
    within(:xpath, "//tr[contains(., '#{video.title}')]") do
      fill_in "queue_items[][position]", with: position
    end
  end

  def expect_video_position(video, position)
    expect(find(:xpath, "//tr[contains(., '#{video.title}')]//input[@type='text']").value).to eq(position.to_s)
  end
end