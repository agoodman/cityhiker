class GridRequestsController < ApplicationController
  
  respond_to :json
  
  def create
    @grid_request = GridRequest.find_or_create_by(min_lat: params[:min_lat], min_lng: params[:min_lng], max_lat: params[:max_lat], max_lng: params[:max_lng])
    respond_with(@grid_request)
  end
  
end
