class SectorsController < ApplicationController
  
  include Serviceable
  
  acts_as_service :sector
  
  skip_before_filter :verify_authenticity_token
  
  @@allowed_factors = [100, 1000]
  @@allowed_key_size = 10
  
  # required params:
  #  scale_key: magnitude truncation factor; 100, 1000 (default)
  #  cell_key: a 10-char base64 string encoding lat/lng
  def assign_existing_instance
    # extract scale_key from params, if valid; default otherwise
    if params[:scale_key] && @@allowed_factors.include?(params[:scale_key].to_i)
      scale = params[:scale_key].to_i
    else
      scale = 1000
    end
    
    # extract cell_key from params, if valid; return empty set otherwise
    if params[:cell_key] && params[:cell_key].length == @@allowed_key_size
      cell = params[:cell_key]
    else
      cell = "0000000000"
    end

    @instance = Sector.find_or_create_by(scale_key: scale, cell_key: cell)
    @instance.validate_state
  end
  
end
