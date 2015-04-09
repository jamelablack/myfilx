require 'spec_helper'


describe QueueItemsController do
	describe "GET index" do
		it "sets @queue_items to queue items for authorized users" do
			amber = Fabricate(:user)
			session[:user_id] = amber.id
			queue_item1 = Fabricate(:queue_item, user: amber)
			queue_item2 = Fabricate(:queue_item, user: amber)
			get :index
			expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
		end
		it "redirects to login page for unauthenticated users" do
			get :index
			expect(response).to redirect_to sign_in_path
		end
	end

	describe "POST create" do
		context "user is authenticated" do
			it "redirects to the my queue page" do
				session[:user_id] = Fabricate(:user).id
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(response).to redirect_to my_queue_path
			end

			it "adds video to my queue page" do
				session[:user_id] = Fabricate(:user).id
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(QueueItem.count).to eq(1)
			end

			it "creates queue item that is associted with video" do
				session[:user_id] = Fabricate(:user).id
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(QueueItem.first.video).to eq(video)
			end

			it "creates queue item that is associated with authenticated user" do
				amber = Fabricate(:user)
				session[:user_id] = amber.id
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(QueueItem.first.user).to eq(amber)
			end

			it "places the most recently added video at the bottom of the queue on my queue page" do
				amber = Fabricate(:user)
				session[:user_id] = amber.id
				broad_city = Fabricate(:video)
				Fabricate(:queue_item, user: amber, video: broad_city)
				girls  = Fabricate(:video)
				post :create, video_id: girls.id
				girls_queue_item = QueueItem.where(video_id: girls.id, user_id: amber.id).first
				expect(girls_queue_item.position).to eq(2)
			end

			it "does not add the video to the queue if the video is already added" do
				amber = Fabricate(:user)
				session[:user_id] = amber.id
				broad_city = Fabricate(:video)
				Fabricate(:queue_item, user: amber, video: broad_city)
				post :create, video_id: broad_city.id
				expect(amber.queue_items.count).to eq(1)
			end
		end

		context "user is unauthenticated" do
			it "redirects to the sign in page for unauthenticated users" do
				post :create, video_id: 3
				expect(response).to redirect_to sign_in_path
			end
		end
	end
end
