class DifferentialController < ApplicationController
  
  # GET /differential?start=lat,lng&end=lat,lng
  def search
    sll = params[:start]
    ell = params[:end]
    slat, slng = sll.split(',')
    elat, elng = ell.split(',')
    slat, slng, elat, elng = [slat,slng,elat,elng].map {|e| e.to_f rescue nil}

    success = false
    alt_delta = 0
    distance = 0
    if [slat,slng,elat,elng].select {|e| e==nil}.empty?
      encoded_polyline = Polylines::Encoder.encode_points([[slat,slng],[elat,elng]])
      url = "https://maps.googleapis.com/maps/api/elevation/json?key=#{ENV['ELEVATION_API_KEY']}&locations=enc:#{encoded_polyline}"
      rsp = HTTParty.get(URI::escape(url))
      if rsp.parsed_response['results']
        results = rsp.parsed_response['results']
        if results.count == 2
          p1 = results[0]
          p2 = results[1]
          seg = RoadSegment.new(start_lat: slat, start_lng: slng, start_alt: p1['elevation'], end_lat: elat, end_lng: elng, end_alt: p2['elevation'])
          alt_delta = p2['elevation'].to_f - p1['elevation'].to_f
          distance = seg.haversine
          success = true
        end
      end
    end
    
    if success
      render text: {elevation_delta: alt_delta, distance: distance}.to_json
    else
      head :bad_request
    end
  end
  
end
