require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

 # Detail.new_token(token,recommendation_id)
 #
 # Detail.for_token(token,lim=20)
 #
 # Detail.for_recommendation(rid,lim=20)
  

describe "details" do
  before do
    @token1 = '4e13456'
    @token2 = '4e23457'
    @token3 = '4e234599'
    @rid1 = Util.ID
    @rid2 = Util.ID
  end
  describe "create" do
    before do
      Detail.collection.remove
    end
    describe "location" do
      before :each do
        Detail.collection.remove
        @before = Detail.collection.count
      end
      it "should create a new detail" do
        Detail.new_token(@token1,@rid1).should == @token1
        (Detail.collection.count - @before).should == 1
      end
      it "should create mutiple new details" do
        Detail.new_token(@token1,@rid1).should == @token1
        Detail.new_token(@token2,@rid2).should == @token2
        Detail.new_token(@token3,@rid1).should == @token3
        (Detail.collection.count - @before).should == 3
      end
    end
  end
  describe "search" do
    before do
      Detail.collection.remove
      Detail.new_token(@token1,@rid1).should == @token1
      Detail.new_token(@token2,@rid2).should == @token2
      Detail.new_token(@token3,@rid1).should == @token3
    end
    describe "token" do
      it "should find detials that the token corresponds to" do
        t1 = Detail.for_token(@token1)
        t2 = Detail.for_token(@token2)
        t3 = Detail.for_token(@token3)
        
        t1.class.should == Array
        t2.class.should == Array
        t3.class.should == Array
        
        t1=t1[0]
        t2=t2[0]
        t3=t3[0]
        
        t1[:token].should == @token1
        t2[:token].should == @token2
        t3[:token].should == @token3
        
        t1['r'].should == @rid1
        t2['r'].should == @rid2
        t3['r'].should == @rid1
      end
    end
    describe "recommendation" do
      it "should find things about locations through the rid of that recommendation" do
        r1 = Detail.for_recommendation(@rid1)
        r2 = Detail.for_recommendation(@rid2)
        r1.length.should == 2
        r2.length.should == 1
      end
    end
  end
end
