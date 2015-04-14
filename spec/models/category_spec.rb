require 'spec_helper'

describe Category do
	it { should have_many(:videos)}


	describe '#recent_videos' do
		it "returns all videos in chronilogical order by created at" do
			comedy = Category.create(name: "Comedy")
			futurama = Video.create(title: "Futurama", description: "Space Travel", created_at: 1.day.ago, category: comedy)
			south_park = Video.create(title: "South Park", description: "Small town fun", created_at: Time.now, category: comedy)
			expect(comedy.recent_videos).to eq([south_park, futurama])
		end
		it "returns all the videos if there are less than six videos" do
			comedy = Category.create(name: "Comedy")
			futurama = Video.create(title: "Futurama", description: "Space Travel", created_at: 1.day.ago, category: comedy)
			south_park = Video.create(title: "South Park", description: "Small town fun", created_at: Time.now, category: comedy)
			expect(comedy.recent_videos.count).to eq(2)
		end
		it "returns six videos if there are more than 6 recent videos" do
				comedy = Category.create(name: "Comedy")
				7.times {Video.create(title: "foo", description: "creating dummy videos", category: comedy)}
				expect(comedy.recent_videos.count).to eq(6)
		end
		it "returns the most recent 6 videos" do
				comedy = Category.create(name: "Comedy")
				7.times {Video.create(title: "foo", description: "creating dummy videos", category: comedy)}
				tonights_show = Video.create(title: "Tonight's Show", description: "Tonight's show will be hilarious!", category: comedy, created_at: 1.day.ago)
				expect(comedy.recent_videos).not_to include(tonights_show)
			end
		it "returns an empty array if the category has zero videos" do
			comedy = Category.create(name: "Comedy")
			expect(comedy.recent_videos).to eq([])
		end
	end
end

