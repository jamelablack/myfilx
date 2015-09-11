require 'spec_helper'

describe Video do
	it { should belong_to(:category)}
	it { should validate_presence_of(:title)}
	it { should validate_presence_of(:description)}
	it { should have_many(:reviews).order(created_at: :desc)}

	describe "search_by_title" do
		it "returns an empty array if there is no match" do
			furturama = Video.create(title: "Futurama", description: "Space Travel")
			back_to_future = Video.create(title: "Back to Future", description: "Time Travel")
			expect(Video.search_by_title("hello")).to eq([])
		end

		it "returns an array of one video for an exact match" do
			futurama = Video.create(title: "Futurama", description: "Space Travel")
			back_to_future = Video.create(title: "Back to Future", description: "Time Travel")
			expect(Video.search_by_title("Futurama")).to eq([futurama])
		end

		it "returns an array of one video for a partial match" do
			futurama = Video.create(title: "Futurama", description: "Space Travel")
			back_to_future = Video.create(title: "Back to Future", description: "Time Travel")
			expect(Video.search_by_title("turama")).to eq([futurama])
		end

		it "returns an array of all matches ordered by created_at" do
			futurama = Video.create(title: "Futurama", description: "Space Travel", created_at: 1.day.ago)
			back_to_future = Video.create(title: "Back to Future", description: "Time Travel")
			expect(Video.search_by_title("Futur")).to eq([back_to_future, futurama])
		end

		it "returns an empty array for a search with an empty string" do
						futurama = Video.create(title: "Futurama", description: "Space Travel", created_at: 1.day.ago)
			back_to_future = Video.create(title: "Back to Future", description: "Time Travel")
			expect(Video.search_by_title("")).to eq([])
		end
	end

  describe ".search", :elasticsearch do
    let(:refresh_index) do
      Video.import
      Video.__elasticsearch__.refresh_index!
    end

    context "with title" do
      it "returns no results when there is no match" do
        Fabricate(:video, title: "Love Actually")
        refresh_index

        expect(Video.search("whatever").records.to_a).to eq []
      end

      it "returns an empty array when there is no search term" do
        love_actually = Fabricate(:video, title: "Love Actually")
        home_alone = Fabricate(:video, title: "Home Alone")
        refresh_index

        expect(Video.search("").records.to_a).to eq []
      end

      it "returns an array of 1 video for title case insensitive match" do
        love_actually = Fabricate(:video, title: "Love Actually")
        home_alone = Fabricate(:video, title: "Home Alone")
        refresh_index

        expect(Video.search("love actually").records.to_a).to eq [love_actually]
      end

      it "returns an array of many videos for title match" do
        home_alone = Fabricate(:video, title: "Home Alone")
        home_alone_2 = Fabricate(:video, title: "Home Alone 2")
        refresh_index

        expect(Video.search("home").records.to_a).to match_array [home_alone, home_alone_2]
      end

    end

    context "with title and description" do
      it "returns an array of many videos based for title and description match" do
        love_actually = Fabricate(:video, title: "Love Actually")
        home_alone = Fabricate(:video, title: "Home Alone", description: "Who doesn't love Kevin and his antics")
        refresh_index

        expect(Video.search("love").records.to_a).to match_array [love_actually, home_alone]
      end
    end

    context "multiple words must match" do
      it "returns an array of videos when two words match title" do
        love_actually = Fabricate(:video, title: "Love Actually")
        home_alone = Fabricate(:video, title: "Home Alone")
        home_alone_2 = Fabricate(:video, title: "Home Alone 2")
        no_place_liked_home = Fabricate(:video, title: "There is no place like home")

        refresh_index

        expect(Video.search("home alone").records.to_a).to match_array [home_alone, home_alone_2]
      end
    end
  end
end
