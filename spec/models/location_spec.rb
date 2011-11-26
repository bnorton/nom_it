require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe "locations" do
  describe "searching" do
    before do
      @lat1 = 40.72381
      @lng1 = -127.403
      @lat2 = 37.82381
      @lng2 = -122.503
      @nid1 = Util.ID
      @nid2 = Util.ID
      @nid3 = Util.ID
      Location.create({
        :nid => @nid1,
        :name => 'location name 1',
        :address => '14 darrell pl',
        :primary => '4e234'})
      Location.create({
        :nid => @nid2,
        :name => 'location 2',
        :address => '2670 parker st',
        :primary => '4e235'})
      Location.create({
        :nid => @nid3,
        :name => 'location name 3',
        :address => '201 11th st',
        :city => 'seal beach',
        :primary => '4e236'})
      Geolocation.create({
        :location_nid => @nid1,
        :lat => @lat1,
        :lng => @lng1})
      Geolocation.create({
        :location_nid => @nid2,
        :lat => @lat2,
        :lng => @lng2})
      Geolocation.create({
        :location_nid => @nid3,
        :lat => @lat2,
        :lng => @lng2})
    end
    
    # @optional :nid
    # @optional :name
    # @optional :street
    # @optional :city
    # def self.search(opt,...)
    it "should find some places near a location in SF" do
      search = Location.search({:lat=>@lat1,:lng=>@lng1,:dist=>1})
      search.class.should == Array
    end
    it "should find a locations based on the nid" do
      
    end
    it "should find a location based on name" do
      one = Location.search({:name =>'location name 1'})
      one.class.should == Array
      one[0]['name'].should == 'location name 1'
      
      two = Location.search({:name =>'location 2'})
      two.class.should == Array
      two[0]['name'].should == 'location 2'
    end
    it "should find a location based on address" do
      one = Location.search({:street =>'14 darrell pl'})
      one.class.should == Array
      one[0]['name'].should == 'location name 1'
      
      two = Location.search({:street =>'2670 parker st'})
      two[0]['name'].should == 'location 2'
      Location.search({:street =>'201 11th st'}).class.should == Array
    end
    it "should find a location based on being somewhere" do
      here = {:lat => @lat1, :lng => @lng1}
      found = Location.search(here)
      found.class.should == Array
      found.length.should == 1
      found[0]['nid'].should == @nid1
    end
    it "should find a location based on street/city" do
      here = {:street => '201 11th',:city => 'seal beach'}
      found = Location.search(here)
      found.class.should == Array
      found.length.should == 1
      found[0]['location_nid'].should == @nid3
    end
    it "should find a location based on street" do
      here = {:street => '2670 parker st',:city => ''}
      found = Location.search(here)
      found.class.should == Array
      found[0]['location_nid'].should == @nid2
    end
    it "should find a location based on strict geolocation" do
      
    end
    it "should find a location based on the text of the descritpion" do
      
    end
    it "should find a location based on the text of the comments" do
      
    end
  end
  describe "creation" do
    it "should not create a new location when geo-loc and" do 
      
    end
    it "should not create when name is missing" do
      
    end
    it "should not create when the rest of the required params are not present" do
      
    end
  end
  describe "tokens" do
    it "should be found by the token that is passed around for the recommendation" do
      
    end
    it "should send back the json of the result assoc with the token" do
      
    end
  end
end

