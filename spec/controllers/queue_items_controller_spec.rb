require 'spec_helper'


describe "QueueItemsController" do
	describe "GET index" do
		it "sets @queue_items to queue items for authorized users" do
			amber = Fabricate(:user)
			session[:user_id] = amber.id
			queue_item1 = Fabricate(:queue_item, user: amber)
			queue_item2 = Fabricate(:queue_item, user: amber)
			get :index
			expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
		end
		it "redirects to login page for unauthenticated users"
	end
end
