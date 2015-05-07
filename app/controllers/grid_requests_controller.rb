class GridRequestsController < ApplicationController
  
  include Serviceable
  
  acts_as_service :grid_request
  
  def assign_new_instance
    @instance = GridRequest.find_or_create_by(min_lat: params[:min_lat], min_lng: params[:min_lng], max_lat: params[:max_lat], max_lng: params[:max_lng])
  end
  
  def assign_collection
    @collection = GridRequest.pending
  end
  
end
