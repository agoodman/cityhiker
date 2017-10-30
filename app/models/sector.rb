class Sector < ActiveRecord::Base
  
  UNKNOWN = 0
  PENDING = 1
  COMPLETE = 2
  
  after_create :generate_grid_request
  
  validates :scale_key, presence: true, numericality: true
  
  validates :cell_key, presence: true, length: { is: 10 }

  validates :state, presence: true, numericality: true
  
  has_many :grid_requests
  
  scope :by_scale, ->(scale,cell) { where(scale_key: scale, cell_key: cell) }

  def generate_grid_request
    min_lat, min_lng, max_lat, max_lng = to_bounds
    request = GridRequest.find_or_create_by(min_lat: min_lat*1e5, min_lng: min_lng*1e5, max_lat: max_lat*1e5, max_lng: max_lng*1e5)
    if request.new_record?
      request.sector_id = id
      request.save
    end
  end
  
  def to_bounds
    sLat = cell_key[0,5] # first half encodes latitude
    sLng = cell_key[5,5] # second half encodes longitude
    min_lat = RoadSegment.base64_to_float(sLat, scale_key)
    puts min_lat
    min_lng = RoadSegment.base64_to_float(sLng, scale_key)
    puts min_lng
    multiplier = scale_key.to_f / 1e5
    puts multiplier
    max_lat = min_lat + multiplier
    max_lng = min_lng + multiplier
    return min_lat, min_lng, max_lat, max_lng
  end
  
  def validate_state
    needs_save = false
    
    # for new records, set state to pending
    if new_record?
      self.state = Sector::PENDING
      needs_save = true
    end
    
    # for existing pending records, check if grid requests have all completed
    if !new_record? && state == Sector::PENDING
      if grid_requests.pending.empty?
        self.state = Sector::COMPLETE
        needs_save = true
      end
    end
    
    if needs_save
      self.save
    end
  end

end
