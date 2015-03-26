class RoadSegmentsController < ApplicationController

  include Serviceable
  
  acts_as_service :road_segment
  
  def did_assign_collection
    per_page = params[:per_page].to_i || 100 rescue 100
    per_page = 1000 if per_page > 1000 || per_page == 0
    @collection = @collection.paginate(page: params[:page] || 1, per_page: per_page)
  end
  
  def is_time_column?(column)
    RoadSegment.columns.select {|e| e.name==column.to_s}.first.type == :timestamp rescue false
  end
  
end
