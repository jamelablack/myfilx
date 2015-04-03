require 'spec_helper'

describe VideosController do
	describe "GET show" do
		it "sets @video for authenticated users" do
			session[:user_id] = Fabricate(:user).id
			video = Fabricate(:video)
			get :show, id: video.id
			expect(assigns(:video)).to eq(video)
		end
		it "sets reviews for authenticated users" do
			session[:user_id] = Fabricate(:user).id
			video = Fabricate(:video)
			review1 = Fabricate(:review, video: video)
			review2 = Fabricate(:review, video: video)
			get :show, id: video.id
			expect(assigns(:reviews)).to match_array([review1, review2])
		end

		it "redirects the user to the sign in page for unauthorized users" do
			video = Fabricate(:video)
			get :show, id: video.id
			expect(response).to redirect_to sign_in_path
		end
	end
	describe "GET search" do
		it "sets @results for authenticated users" do
			session[:user_id] = Fabricate(:user).id
			broad_city = Fabricate(:video, title: 'Broad City')
			get :search, search_term: 'city'
			expect(assigns(:results)).to eq([broad_city])
		end
		it "redirects to sign in page for unauthenticated users" do
			broad_city = Fabricate(:video, title: 'Broad City')
			get :search, search_term: 'city'
			expect(response).to redirect_to sign_in_path
		end
	end
end