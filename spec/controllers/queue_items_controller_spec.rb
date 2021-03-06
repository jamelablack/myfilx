require 'spec_helper'


describe QueueItemsController do
	describe "GET index" do
		it "sets @queue_items to queue items for authorized users" do
			amber = Fabricate(:user)
			set_current_user(amber)
			queue_item1 = Fabricate(:queue_item, user: amber)
			queue_item2 = Fabricate(:queue_item, user: amber)
			get :index
			expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
		end

		it_behaves_like "requires sign in" do
			let(:action) { get :index }
		end
	end

	describe "POST create" do
		context "user is authenticated" do
			it "redirects to the my queue page" do
				set_current_user
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(response).to redirect_to my_queue_path
			end

			it "adds video to my queue page" do
				set_current_user
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(QueueItem.count).to eq(1)
			end

			it "creates queue item that is associted with video" do
				set_current_user
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(QueueItem.first.video).to eq(video)
			end

			it "creates queue item that is associated with authenticated user" do
				amber = Fabricate(:user)
				set_current_user(amber)
				video = Fabricate(:video)
				post :create, video_id: video.id
				expect(QueueItem.first.user).to eq(amber)
			end

			it "places the most recently added video at the bottom of the queue on my queue page" do
				amber = Fabricate(:user)
				set_current_user(amber)
				broad_city = Fabricate(:video)
				Fabricate(:queue_item, user: amber, video: broad_city)
				girls  = Fabricate(:video)
				post :create, video_id: girls.id
				girls_queue_item = QueueItem.where(video_id: girls.id, user_id: amber.id).first
				expect(girls_queue_item.position).to eq(2)
			end

			it "does not add the video to the queue if the video is already added" do
				amber = Fabricate(:user)
				set_current_user(amber)
				broad_city = Fabricate(:video)
				Fabricate(:queue_item, user: amber, video: broad_city)
				post :create, video_id: broad_city.id
				expect(amber.queue_items.count).to eq(1)
			end
		end

		context "user is unauthenticated" do
			it_behaves_like "requires sign in" do
				let(:action) { post :create, video_id: 3 }
			end
		end
	end

	describe "DELETE destroy" do
		it "redirects to the my queue page" do
			set_current_user
			queue_item = Fabricate(:queue_item)
			delete :destroy, id: queue_item.id
			expect(response).to redirect_to my_queue_path
		end

		it "deletes the queue item" do
			amber = Fabricate(:user)
			set_current_user(amber)
			queue_item = Fabricate(:queue_item)
			delete :destroy, id: queue_item.id
			expect(QueueItem.count).to eq(1)
		end

		it "does not delete the queue item if the queue item is not in the current_user's queue" do
			amber = Fabricate(:user)
			bob = Fabricate(:user)
			session[:user_id] = amber.id
			queue_item = Fabricate(:queue_item, user: bob)
			delete :destroy, id: queue_item.id
			expect(QueueItem.count).to eq(1)
		end

		it_behaves_like "requires sign in" do
			let(:action) { delete :destroy, id: 3 }
		end

		it "normalizes the remaining queue_item positions" do
			alice = Fabricate(:user)
			session[:user_id] = alice.id
			queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
			queue_item2 = Fabricate(:queue_item, user: alice, position: 2)
			delete :destroy, id: queue_item1.id
			expect(QueueItem.first.position).to eq(1)
		end
	end

 describe "POST update_queue" do

 	it_behaves_like "requires sign in" do
 		let(:action) do
			post :update_queue, queue_items: [{ id: 2, position: 3}, {id: 5, position: 2}]
		end
	end

 	context "with all valid inputs" do
 		let(:alice)  { Fabricate(:user) }
		let(:video) { Fabricate(:video) }
		let(:queue_item1) { Fabricate(:queue_item, user: alice, position: 1, video: video) }
		let(:queue_item2) { Fabricate(:queue_item, user: alice, position: 2, video: video) }

		before { set_current_user(alice) }

	 	it "redirects to the my queue page" do
	 		post :update_queue, queue_items:[{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
	 		expect(response).to redirect_to my_queue_path
	 	end

	 	it "reorders the queue item" do
	 		post :update_queue, queue_items:[{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
	 		expect(alice.queue_items).to eq([queue_item2, queue_item1])
	 	end

	 	it "normalizes the position numbers" do
	 		post :update_queue, queue_items:[{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 1}]
	 		expect(alice.queue_items.map(&:position)).to eq([1,2])
	 	end
	end

	 context "with invalid inputs" do
	 	let(:alice) { Fabricate(:user) }
		let(:video) { Fabricate(:video) }
		let(:queue_item1) { Fabricate(:queue_item, user: alice, position: 1, video: video) }
		let(:queue_item2) { Fabricate(:queue_item, user: alice, position: 2, video: video) }

		before { set_current_user(alice) }


	 	it "redirects to the my queue page" do
	 		post :update_queue, queue_items:[{id: queue_item1.id, position: 3.4}, {id: queue_item2.id, position: 1}]
	 		expect(response).to redirect_to my_queue_path
	 	end

	 	it "sets the flash error message" do
	 		post :update_queue, queue_items:[{id: queue_item1.id, position: 3.4}, {id: queue_item2.id, position: 1}]
	 		expect(flash[:error]).to be_present
	 	end

	 	it "does not change the queue items" do
	 		post :update_queue, queue_items:[{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2.1}]
	 		expect(queue_item1.reload.position).to eq(1)
	 	end
	 end


	 context "with queue items that do not belong the current user" do
	 	it "does not change the queue items" do
	 		alice = Fabricate(:user)
	 		set_current_user(alice)
	 		bob = Fabricate(:user)
	 		video = Fabricate(:video)
	 		queue_item1 = Fabricate(:queue_item, user: bob, position: 1, video: video)
	 		queue_item2 = Fabricate(:queue_item, user: alice, position: 2, video: video)
	 		post :update_queue, queue_items:[{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2}]
	 		expect(queue_item1.reload.position).to eq(1)
	 	end
	 end
	end
end
