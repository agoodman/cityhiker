class ElevationRequest < ActiveRecord::Base
  
  has_many :elevation_request_segments
  
  def generate_segments(ways=[])
    ways.each.with_index {|way,k| elevation_request_segments.create(way_id: way.id, index: k)}
  end
  
  def generate_polylines
    points = []
    index = []
    k = 0
    elevation_request_segments.each do |seg|
      nodes = OpenStreetMap::Way.find(seg.way_id).nodes.split(',').map {|ref| OpenStreetMap::Node.where(ref: ref).first}
      nodes.each {|node| points.push([node.lat,node.lng])}
      k = k + nodes.count
      index.push(k)
    end
    self.encoded_polyline = Polylines::Encoder.encode_points(points)
    self.index_map = index.join(',')
    self.save
  end
  
  def process
    url = "https://maps.googleapis.com/maps/api/elevation/json?key=#{ENV['ELEVATION_API_KEY']}&locations=enc:#{encoded_polyline}"
    rsp = HTTParty.get(URI::escape(url))
    if rsp.parsed_response['results']
      results = rsp.parsed_response['results']
      last_index = 0
      index_map.split(',').each do |index|
        k1 = last_index
        k2 = index.to_i - 1
        k2 = results.count - 1 if k2 > results.count - 1
        for k in (k1..k2-1)
          p1 = results[k]
          p2 = results[k+1]
          next unless (p1['location'] && p1['elevation'] && p2['location'] && p2['elevation'] rescue false)
          seg = RoadSegment.new(
            start_lat: p1['location']['lat'], 
            start_lng: p1['location']['lng'], 
            start_alt: p1['elevation'],
            end_lat: p2['location']['lat'],
            end_lng: p2['location']['lng'],
            end_alt: p2['elevation']
          )
          seg.calculate_grade
        end
        last_index = k2 + 1
      end
    end
  end
  
end
