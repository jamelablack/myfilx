require 'spec_helper'

describe VideosController do
	describe "GET show" do
		it "sets @video for authenticated users" do
			set_current_user
			video = Fabricate(:video)
			get :show, id: video.id
			expect(assigns(:video)).to eq(video)
		end
		context "authenticated users" do
			it "sets reviews for authenticated users" do
				set_current_user
				video = Fabricate(:video)
				review1 = Fabricate(:review, video: video)
				review2 = Fabricate(:review, video: video)
				get :show, id: video.id
				expect(assigns(:reviews)).to match_array([review1, review2])
			end
		end

		context "sets reviews for unauthenticated users" do
			it_behaves_like "requires sign in" do
				let(:action) { get :show, id: 3 }
			end
		end
	end
	describe "GET search" do
		it "sets @results for authenticated users" do
			set_current_user
			broad_city = Fabricate(:video, title: 'Broad City')
			get :search, search_term: 'city'
			expect(assigns(:results)).to eq([broad_city])
		end
		context "redirects to sign in page for unauthenticated users" do
			it_behaves_like "requires sign in" do
				let(:action) { get :search, search_term: 'city'}
			end
		end
	end
end
