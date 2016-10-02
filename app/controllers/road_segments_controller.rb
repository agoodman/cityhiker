class RoadSegmentsController < ApplicationController

  include Serviceable
  
  acts_as_service :road_segment
  
  @@allowed_factors = [1000, 10000, 100000]
  @@allowed_key_size = 10
  
  # required params:
  #  factor: magnitude truncation factor; 1000 (default), 10000, or 100000
  #  hecto_key: a 10-char base64 string encoding lat/lng
  def hecto
    # extract factor from params, if valid; default otherwise
    if params[:factor] && @@allowed_factors.include?(params[:factor])
      factor = params[:factor]
    else
      factor = 1000
    end
    
    # extract key from params, if valid; return empty set otherwise
    if params[:hecto_key] && params[:hecto_key].length == @@allowed_key_size
      hecto_key = params[:hecto_key]

      @collection = Rails.cache.fetch("#{factor}/#{hecto_key}", expires_in: 12.hours) do
        RoadSegment.where(hecto_key: hecto_key)
      end
    else
      @collection = []
    end
    
    respond_to do |format|
      format.json { render json: @collection.map(&:as_base64).to_json }
    end
  end
  
  def did_assign_collection
    per_page = params[:per_page].to_i || 100 rescue 100
    per_page = 1000 if per_page > 1000 || per_page == 0
    @collection = @collection.paginate(page: params[:page] || 1, per_page: per_page)
  end
  
  def is_time_column?(column)
    RoadSegment.columns.select {|e| e.name==column.to_s}.first.type == :timestamp rescue false
  end
  
end
