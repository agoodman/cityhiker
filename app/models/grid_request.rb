class GridRequest < ActiveRecord::Base
  
  before_save :generate_url
  after_create :process_request
  
  scope :pending, lambda { where(completed_at: nil) }
  
  def generate_url
    self.url = "http://api.openstreetmap.org/api/0.6/map?bbox=%3.5f,%3.5f,%3.5f,%3.5f" % [min_lng.to_f/1e5,min_lat.to_f/1e5,max_lng.to_f/1e5,max_lat.to_f/1e5]
  end
  
  def process_request
    self.delay.process
  end
  
  def process
    rsp = HTTParty.get(url)
    osm = rsp.parsed_response['osm']
    if osm
      if osm['node']
        osm['node'].each {|node| OpenStreetMap::Node.find_or_create_by(ref: node['id'], lat: node['lat'].to_f, lng: node['lon'].to_f)}
        new_ways = []
        if osm['way']
          osm['way'].select {|way| way['tag']!=nil && way['tag'].any? {|tag| tag['k']=='highway'} rescue false}.each {|way| new_ways.push OpenStreetMap::Way.create(ref: way['id'], nodes: way['nd'].map {|node| node['ref']}.join(','))}
          if new_ways.any?
            er = ElevationRequest.create
            er.generate_segments(new_ways)
            er.generate_polylines
            er.process
          end
        end
      end
    end
    self.completed_at = Time.now
    self.save
  end
  
end
