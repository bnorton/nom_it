require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do
  
# create
# recommendation
# location
# user
# search
  
  describe "#create" do
    before do
      @lnid1 = Util.ID
      @lnid2 = Util.ID
      @location1 = {:location_nid=>@lnid1,:user_nid=>Util.ID,:text=>'sample comment'}
      @location2 = {:location_nid=>@lnid1,:user_nid=>Util.ID,:text=>'sample comment2'}
      @location3 = {:location_nid=>@lnid2,:user_nid=>Util.ID,:text=>'sample comment17'}
      @location4 = {:location_nid=>@lnid2,:user_nid=>Util.ID,:text=>'sample comment23'}

    end
    it "should make a new commnt about a location" do
      User.stub!(:valid_session?).and_return(true)
      post :create, :format => :json, :location_nid=>@lnid1, :auth_token => Digest::SHA2.hexdigest(rand(1<<16).to_s)
      puts JSON.parse(response.body)
    end
    it "should make a new commnt about a user" do
      pending
    end
  end
  describe "#recommendation" do
    it "should find comments about a recommendation" do
      pending
    end
  end
  describe "#location" do
    it "should find comments about a location" do
      pending
    end
  end
  describe "#user" do
    it "should find the comments about a user" do
      pending
    end
  end
  describe "#search" do
    it "should " do
      pending
    end
  end
end