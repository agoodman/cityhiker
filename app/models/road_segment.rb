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
