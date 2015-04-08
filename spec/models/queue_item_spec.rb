require 'spec_helper'

describe QueueItem do 
	it { should belong_to(:user) }
	it { should belong_to(:video) }

	describe "@video_title" do
		it "returns the title of the associated video" do
			video = Fabricate(:video, title: "Broad City")
			queue_item = Fabricate(:queue_item, video: video)
			expect(queue_item.video_title).to eq("Broad City")
		end
	end

	describe "queue_item.rating" do
		it "returns a rating from the review when a review is present" do
			video  = Fabricate(:video)
			user = Fabricate(:user)
			review = Fabricate(:review, user: user, video: video, rating: 4)
			queue_item = Fabricate(:queue_item, user: user, video: video)
			expect(queue_item.rating).to eq(4)
		end

		it "returns nil when the rating is not present" do
			video  = Fabricate(:video)
			user = Fabricate(:user)
			queue_item = Fabricate(:queue_item, user: user, video: video)
			expect(queue_item.rating).to eq(nil)
		end
	end

	describe "#category_name" do
		it "returns category's name for the associated video" do
			category = Fabricate(:category, name: "Comedy")
			video  = Fabricate(:video, category:  category)
			queue_item = Fabricate(:queue_item, video: video)
			expect(queue_item.category_name).to eq("Comedy")
		end
	end

	describe "#category" do
		it "returns the category for the associated video" do
			category = Fabricate(:category)
			video  = Fabricate(:video, category:  category)
			queue_item = Fabricate(:queue_item, video: video)
			expect(queue_item.category).to eq(category)
		end
	end
end