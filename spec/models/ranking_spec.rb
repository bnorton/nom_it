require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  # Ranking.new_rank(nid,uid,value,text='')
  # Ranking.remove_rank(nid,uid)
  # Ranking.for_uid(uid)
  # Ranking.for_nid(nid)
  
  
  # RankingAverage.new_ranking(nid,rating)
  # RankingAverage.update_ranking(nid,old_r,new_r)
  # RankingAverage.remove_ranking(nid,old_value)
  # RankingAverage.ranking(nid)
  # RankingAverage.total(nid)
  # RankingAverage.ranking_total(nid)


describe "ranking" do
  before do
    @nid1 = '4e13456'
    @nid2 = '4e23457'
    @nid3 = '4e23459'
    @uid1 = '5f66'
    @uid2 = '5f55'
    @uid3 = '5f44'
  end
  describe "create" do
    before do
      Ranking.collection.remove
    end
    describe "location" do
      before :each do
        @before = Ranking.collection.count
        Ranking.collection.remove
        RankingAverage.collection.remove
      end
      it "should create a new ranking" do
        Ranking.new_rank(@nid1,@uid1,1,'sample').should == true
        (Ranking.collection.count - @before).should == 1
      end
      it "should create mutiple new rankings" do
        Ranking.new_rank(@nid1,@uid1,1,'sample').should == true
        Ranking.new_rank(@nid1,@uid2,2,'sample').should == true
        Ranking.new_rank(@nid1,@uid3,1,'sample').should == true
        Ranking.new_rank(@nid2,@uid1,2,'sample').should == true
        Ranking.new_rank(@nid2,@uid2,4,'sample').should == true
        Ranking.new_rank(@nid2,@uid3,3,'sample').should == true
        (Ranking.collection.count - @before).should == 6
      end
      it "should propagate the new_ranks out to the average as well" do
        Ranking.new_rank(@nid1,@uid1,1,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(1.0)
        Ranking.new_rank(@nid1,@uid2,2,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(1.5)
        Ranking.new_rank(@nid1,@uid3,3,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(2.0) 
      end
      it "should update the rank when it is a different value from from the original" do
        Ranking.new_rank(@nid1,@uid1,1,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(1.0) 
        Ranking.new_rank(@nid1,@uid1,2,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(2.0) 
        Ranking.new_rank(@nid1,@uid1,5,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(5.0) 
      end
      it "should keep the same count when the rating is updated" do
        Ranking.new_rank(@nid1,@uid1,1,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(1.0)
        RankingAverage.total(@nid1).should  == 1
        Ranking.for_uid(@uid1).count.should == 1
        
        Ranking.new_rank(@nid1,@uid1,2,'sample').should == true
        RankingAverage.ranking(@nid1).should be_within(0.001).of(2.0)
        RankingAverage.total(@nid1).should  == 1
        Ranking.for_uid(@uid1).count.should == 1
      end
      it "should update the average when the value is reused for another location" do
        Ranking.new_rank(@nid1,@uid1,1,'sample').should == true
        Ranking.new_rank(@nid2,@uid1,1,'sample').should == true
        Ranking.new_rank(@nid3,@uid1,1,'sample').should == true
        
        RankingAverage.ranking(@nid1).should be_within(0.001).of(1.0)
        RankingAverage.ranking(@nid2).should be_within(0.001).of(1.0)
        RankingAverage.ranking(@nid3).should be_within(0.001).of(1.0)
        
        RankingAverage.total(@nid1).should  == 1
        RankingAverage.total(@nid2).should  == 1
        
        RankingAverage.total(@nid3).should  == 1
      end
    end
  end
  describe "search" do
    before do
      Ranking.collection.remove
      @before = Ranking.collection.count
      Ranking.new_rank(@nid1,@uid1,1,'sample').should == true
      Ranking.new_rank(@nid1,@uid2,2,'sample').should == true
      Ranking.new_rank(@nid1,@uid3,1,'sample').should == true
      Ranking.new_rank(@nid2,@uid2,2,'sample').should == true
      Ranking.new_rank(@nid2,@uid3,4,'sample').should == true
      Ranking.new_rank(@nid3,@uid3,3,'sample').should == true
      (Ranking.collection.count - @before).should == 6
    end
    describe "user" do
      it "should find ranks by the users specified" do
        Ranking.for_uid(@uid1).count.should == 1
        Ranking.for_uid(@uid2).count.should == 2
        Ranking.for_uid(@uid3).count.should == 3
      end
    end
    describe "location" do
      it "should find things about locations through the nid of that location" do
        Ranking.for_nid(@nid1).count.should == 3
        Ranking.for_nid(@nid2).count.should == 2
        Ranking.for_nid(@nid3).count.should == 1
      end
    end
  end
end
