require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe "locations" do
  describe "searching" do
    before do
      @lat = 37.72381
      @lng = -122.403
    end
    it "should find some places near a location in SF" do
      Geolocation.search_by_geolocation({:lat=>@lat,:lng=>@lng,:dist=>1})
    end
  end
end