require 'test_helper'

class RoadSegmentTest < ActiveSupport::TestCase

  def test_float_to_int26
    iVal = RoadSegment.float_to_int26(38.86543, 100000)
    sVal = RoadSegment.int26_to_base64(iVal)
    assert_equal("ao03p", sVal)
  end

end
