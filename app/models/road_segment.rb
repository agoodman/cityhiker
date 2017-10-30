class RoadSegment < ActiveRecord::Base
  
  validates_presence_of :start_lat, :start_lng, :start_alt, :end_lat, :end_lng, :end_alt
  
  def calculate_grade
    run = haversine
    rise = end_alt - start_alt
    self.percent_grade = 100.0 * rise.to_f / run.to_f
    self.save unless percent_grade.nan?
  end
  
  def haversine
    return Math.haversine(start_lat, start_lng, end_lat, end_lng)
  end
  
  def self.by_factor(factor=1000, key)
    if factor == 1000
      self.where(hecto_key: key)
    elsif factor == 100
      self.where(kilo_key: key)
    end
  end
  
  def generate_hecto_key
    encoded_lat = RoadSegment.float_to_base64(start_lat, 1000)
    encoded_lng = RoadSegment.float_to_base64(start_lng, 1000)
    self.hecto_key = encoded_lat + encoded_lng
  end

  def generate_kilo_key
    encoded_lat = RoadSegment.float_to_base64(start_lat, 100)
    encoded_lng = RoadSegment.float_to_base64(start_lng, 100)
    self.kilo_key = encoded_lat + encoded_lng
  end

  def as_base64
    lat0 = RoadSegment.float_to_base64(start_lat, 100000)
    lng0 = RoadSegment.float_to_base64(start_lng, 100000)
    alt0 = RoadSegment.float_to_base64(start_alt, 100000)
    lat1 = RoadSegment.float_to_base64(end_lat, 100000)
    lng1 = RoadSegment.float_to_base64(end_lng, 100000)
    alt1 = RoadSegment.float_to_base64(end_alt, 100000)
    grade = RoadSegment.float_to_base64(percent_grade, 100000)
    guid = RoadSegment.float_to_base64(id, 1)
    lat0 + lng0 + alt0 + lat1 + lng1 + alt1 + grade + guid
  end
  
  def self.float_to_base64(value, factor)
    int26_to_base64(float_to_int26(value, factor))
  end
  
  def self.float_to_int26(value, factor)
    int_val = 0

    if value < 0 
      int_val |= (0x1 << 25)
    end

    uint_val = Integer(value.abs * factor)

    int_val = int_val | uint_val

    return int_val
  end
  
  def self.int26_to_float(value, factor)
    valueMask = 0x01FFFFFF
    
    uVal = value & valueMask
    
    iVal = Integer(uVal)
    
    fVal = iVal.to_f / factor.to_f
    
    if value & (0x1 << 25) != 0
      fVal = -fVal
    end
    
    return fVal
  end
  
  def self.base64_to_float(value, factor)
    iVal = base64_to_int26(value)
    return int26_to_float(iVal, factor)
  end
  
  @@base64_characters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "-"]
  
  def self.int26_to_base64(value)
    mask = 0x01 | 0x02 | 0x04 | 0x08 | 0x10 | 0x20
    (0..4)
      .map { |i|
        cursor = Integer(i * 6)
        rolling_mask = Integer(mask << cursor)
        unshifted = value & rolling_mask
        shifted = unshifted >> cursor
        raw_char = shifted
        char = @@base64_characters[raw_char]
      }
      .join
      .reverse
  end
  
  def self.base64_to_int26(value)
    if value.length != 5
      return 0
    end
    
    result = 0
    
    (0..4)
      .each { |i|
        cursor = Integer(i * 6)
        char = value[4-i]
        index = @@base64_characters.index(char)
        shiftedRawChar = index
        unshiftedRawChar = shiftedRawChar << cursor
        result |= unshiftedRawChar
      }
      
    return result
  end
  
  def self.scoped
    self.all
  end
  
  def self.export_kml(segments=[])
    builder = Nokogiri::XML::Builder.new do |doc|
      doc.kml('xmlns' => 'http://earth.google.com/kml/2.0') {
        doc.Document {
          segments.each do |seg|
            doc.Placemark {
              doc.LineString {
                doc.coordinates "#{seg.start_lng},#{seg.start_lat},#{seg.start_alt} #{seg.end_lng},#{seg.end_lat},#{seg.end_alt}"
              }
              doc.Style {
                doc.LineStyle {
                  doc.width 5
                  doc.color grade_color(seg.percent_grade)
                }
              }
            }
          end
        }
      }
    end
    kml_file = File.open("road_segments.kml", "wb")
    kml_file.write(builder.to_xml)
    kml_file.close
  end

  def self.grade_color(grade)
    abs_grade = grade.abs
    if abs_grade<2
      return "ff00ff00"
    elsif abs_grade<10
      return "ff00ffff"
    elsif abs_grade<20
      return "ff00aaff"
    else
      return "ff0000ff"
    end
  end
  
end

module Math
  def self.haversine(lat1,lng1,lat2,lng2)
    radius = 6371000
    phi1 = lat1 * Math::PI / 180.0
    phi2 = lat2 * Math::PI / 180.0
    delta_phi = phi2 - phi1
    delta_lam = (lng2 - lng1) * Math::PI / 180.0
    sdp = Math.sin(delta_phi / 2.0)
    sdl = Math.sin(delta_lam / 2.0)
    a = sdp * sdp + Math.cos(phi1) * Math.cos(phi2) * sdl * sdl
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return radius * c
  end
end
