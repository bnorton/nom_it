require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  # Thumb.new_thumb(nid,uid,value)
  # Thumb.for_uid(uid,lim=20)
  # Thumb.for_nid(nid,lim=20)
  # 
  # ThumbCount.update_thumb_count(nid,value)
  # ThumbCount.for_nid(nid)   ==>   { :up => item['up'], :meh => item['meh'], :nid => nid }


describe "thumbs" do
  before do
    @nid1 = Util.ID
    @nid2 = Util.ID
    @uid1 = Util.ID
    @uid2 = Util.ID
  end
  describe "create" do
    before do
      Ranking.collection.remove
    end
    describe "location" do
      before :each do
        Thumb.collection.remove
        ThumbCount.collection.remove
        @before_t  = Thumb.collection.count
        @before_tc = ThumbCount.collection.count
      end
      it "should create a new thumb" do
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.meh).should == true
        (Thumb.collection.count - @before_t).should == 1
      end
      it "should create mutiple new thumbs" do
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.up).should  == true
        Thumb.new_thumb(@nid1,@uid2,ThumbCount.up).should  == true
        Thumb.new_thumb(@nid2,@uid1,ThumbCount.meh).should == true
        Thumb.new_thumb(@nid2,@uid2,ThumbCount.meh).should == true
        (Thumb.collection.count - @before_t).should == 4
      end
      it "should propagate the new thumbs out to the count as well" do
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.up).should  == true
        Thumb.new_thumb(@nid1,@uid2,ThumbCount.up).should  == true
        Thumb.new_thumb(@nid2,@uid1,ThumbCount.meh).should == true
        Thumb.new_thumb(@nid2,@uid2,ThumbCount.meh).should == true
        (Thumb.collection.count - @before_t).should == 4
        nid1 = ThumbCount.for_nid(@nid1)
        nid2 = ThumbCount.for_nid(@nid2)
        puts "NID1 #{nid1.inspect}"
        nid1[:up].should  == 2
        nid1[:meh].should == 0
        nid2[:up].should  == 0
        nid2[:meh].should == 2
        
        nid1[:nid].should == @nid1
        nid2[:nid].should == @nid2
      end
      it "should update the thumb when it is a different value from from the original" do
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.up).should  == true
        ThumbCount.for_nid(@nid1)[:up].should == 1
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.meh).should  == true
        ThumbCount.for_nid(@nid1)[:meh].should == 1
      end
      it "should reject the identical thumb and update to a new value" do
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.up).should   == true
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.up).should   == false
        puts "ThumbCount #{ThumbCount.for_nid(@nid1).inspect}"
        ThumbCount.for_nid(@nid1)[:up].should == 1
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.meh).should  == true
        Thumb.new_thumb(@nid1,@uid1,ThumbCount.meh).should  == false
        ThumbCount.for_nid(@nid1)[:meh].should == 1
      end
    end
  end
  describe "search" do
    before do
      Thumb.collection.remove
      ThumbCount.collection.remove
      Thumb.new_thumb(@nid1,@uid1,ThumbCount.up).should  == true
      Thumb.new_thumb(@nid2,@uid1,ThumbCount.meh).should == true
    end
    describe "user" do
      it "should find thumbs by the users specified" do
        uid = Thumb.for_uid(@uid1)
        uid.count.should == 2
        uid.count.times do
          u = uid.next
          if u[:nid] == @nid1
            u[:value].should == ThumbCount.up
          end
          if u[:nid] == @nid2
            u[:value].should == ThumbCount.meh
          end
        end
      end
    end
    describe "location" do
      it "should find things about locations through the nid of that location" do
        nid = Thumb.for_nid(@nid1)
        nid.count.should == 1
        n = nid.next
        n['value'].should == ThumbCount.up
        
        nid = Thumb.for_nid(@nid2)
        nid.count.should == 1
        n = nid.next
        n['value'].should == ThumbCount.meh
      end
    end
  end
end
