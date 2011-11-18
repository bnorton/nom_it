require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "comments" do
  describe "input validations" do
    before do
      Comment.collection.remove
      @unid1 = Util.ID
      @lnid1 = Util.ID
      @unid1 = Util.ID
      @txtfail1 = {:user_nid => @unid1, :location_nid => @lnid1}
      @txtfail2 = {:user_nid => @unid1, :location_nid => @lnid1, :recommendation_nid => @rnid1}
      @locfail1 = {:user_nid => @unid1, :text => 'sample'}
      @locfail2 = {:location_nid => @unid1, :text => 'sample'}
      @recfail1 = @locfail1.merge({:location_nid => @lnid1})
      @recfail2 = @locfail2.merge({:user_nid => @unid1})
      @nidfail= {:text => "sample"}
      @searchfail1 = {}
    end
    it "should reject an empty hash" do
      Comment.create_comment_for_location({}).should == false
      Comment.create_comment_for_recommendation({}).should == false
    end
    it "should reject a location comment if the text is not present" do
      Comment.create_comment_for_location(@txtfail1).should == false
      Comment.create_comment_for_location(@txtfail2).should == false
      Comment.create_comment_for_recommendation(@txtfail1).should == false
      Comment.create_comment_for_recommendation(@txtfail2).should == false
    end
    it "should reject a location comment of the lnid and unid are not specified" do
      Comment.create_comment_for_location(@locfail1).should == false
      Comment.create_comment_for_location(@locfail2).should == false
    end
    it "should reject a recommendation comment of the rnid, lnid and unid are not specified" do
      Comment.create_comment_for_recommendation(@recfail1).should == false
      Comment.create_comment_for_recommendation(@recfail2).should == false
    end
    it "should reject a new comment if it doesnt at least have a nid" do
      Comment.create_comment_for_recommendation(@nidfail).should == false
      Comment.create_comment_for_location(@nidfail).should == false
    end
    it "should reject a search if none of the correct parameters are not specified" do
      pending
    end
    it "should not find any items that match any of the query items from this run" do
      pending
    end
  end
  describe "create" do
    before do
      Comment.collection.remove
    end
    # create_comment_for_location(options) => must include lnid, unid, text
    describe "location" do
      before do
        lnid1 = Util.ID
        lnid2 = Util.ID
        @location1 = {:location_nid=>lnid1,:user_nid=>Util.ID,:text=>'sample comment'  }
        @location2 = {:location_nid=>lnid1,:user_nid=>Util.ID,:text=>'sample comment2' }
        @location3 = {:location_nid=>lnid2,:user_nid=>Util.ID,:text=>'sample comment17'}
        @location4 = {:location_nid=>lnid2,:user_nid=>Util.ID,:text=>'sample comment23'}
      end
      before :each do
        @before = Comment.collection.size
      end
      it "should create a new comment for a location" do
        Comment.create_comment_for_location(@location1).class.should == String
        (Comment.collection.count - @before).should == 1
      end
      it "should create multiple comments for various locations" do
        Comment.create_comment_for_location(@location1).class.should == String
        Comment.create_comment_for_location(@location2).class.should == String
        (Comment.collection.count - @before).should == 2
        
        Comment.create_comment_for_location(@location3).class.should == String
        Comment.create_comment_for_location(@location4).class.should == String
        (Comment.collection.count - @before).should == 4
      end
      it "should then find the created comments based on the criteria" do
        
      end
    end
    # create_comment_for_recommendation (option) => must include rnid, lnid, unid, text
    describe "recommendations" do
      before do
        rnid1 = Util.ID
        rnid2 = Util.ID
        lnid1 = Util.ID
        lnid2 = Util.ID
        @recommendation1 = {:recommendation_nid=>rnid1,:location_nid=>lnid1,:user_nid=>Util.ID,:text=>'sample comment'}
        @recommendation2 = {:recommendation_nid=>rnid1,:location_nid=>lnid1,:user_nid=>Util.ID,:text=>'sample comment2 from user 3'}
        @recommendation3 = {:recommendation_nid=>rnid1,:location_nid=>lnid1,:user_nid=>Util.ID,:text=>'sample comment17'}
        @recommendation4 = {:recommendation_nid=>rnid2,:location_nid=>lnid2,:user_nid=>Util.ID,:text=>'sample comment23'}
        @oid = BSON::ObjectId.new.to_s
        @recommendation_nid = {:nid=>@oid,:text=>"sample with a nid how about that"}
      end
      before :each do
        @before = Comment.collection.count
      end
      it "should create a new comment for a recommendation" do
        Comment.create_comment_for_recommendation(@recommendation1).class.should == String
        (Comment.collection.count - @before).should == 1
      end
      it "should create a few new comments for a single recommendation" do
        Comment.create_comment_for_recommendation(@recommendation1).class.should == String
        Comment.create_comment_for_recommendation(@recommendation2).class.should == String
        Comment.create_comment_for_recommendation(@recommendation3).class.should == String
        (Comment.collection.count - @before).should == 3
      end
      it "should then find the created items based on the search criteria" do
        pending
      end
    end
  end
  # destroy(opt={})
  #   return false unless Comment.check_params(opt)
  # 
  # destroy_id(id)
  describe "destroy" do
    before do
      rnid1 = Util.ID
      lnid1 = Util.ID
      Comment.collection.remove
      @recommendation1 = {:recommendation_nid=>rnid1,:location_nid=>lnid1,:user_nid=>Util.ID,:text=>'sample comment'}
      @recommendation2 = {:recommendation_nid=>rnid1,:location_nid=>lnid1,:user_nid=>Util.ID,:text=>'sample comment2 from user 3'}
    end
    before :each do
      @before = Comment.collection.count
      @id1 = Comment.create_comment_for_recommendation(@recommendation1)
      @id2 = Comment.create_comment_for_recommendation(@recommendation2)
      @after = Comment.collection.count
      (@after - @before).should == 2
    end
    it "should remove any comemnts that were specified for delete" do
      Comment.destroy_nid(@id1)
      Comment.destroy_nid(@id2)
      (Comment.collection.count - @after).should == 0
    end
    it "should remove all comments that match the unid, lnid (all of a users comments about a location)" do
      pending "should destroy based on the comment_nid only"
      r = @recommendation1
      finder = {:user_nid => r[:user_nid], :location_nid => r[:location_nid]}
      Comment.destroy(finder)
      (Comment.collection.count - @after).should == 0
      comment = Comment.search(finder).first
      comment['text'].should == Comment.removed_content_message
      
      r = @recommendation2
      finder = {:user_nid => r[:user_nid], :location_nid => r[:location_nid]}
      Comment.destroy(finder)
      (Comment.collection.count - @after).should == 0
      comment = Comment.search(finder).first
      comment['text'].should == Comment.removed_content_message
    end
    it "should remove all comments that match the recommendation_nid, unid, lnid (all of a users comments about a location)" do
      pending "should destroy based on the comment_nid only"
      r = @recommendation1
      Comment.destroy({:recommendation_nid => r[:recommendation_nid], :user_nid => r[:user_nid], :location_nid => r[:location_nid]})
      (Comment.collection.count - @after).should == 0
      
      r = @recommendation2
      Comment.destroy({:recommendation_nid => r[:recommendation_nid], :user_nid => r[:user_nid], :location_nid => r[:location_nid]})
      (Comment.collection.count - @after).should == 0
    end
    it "should have the common verbage for a deleted comment with user data still attached" do
      pending "should destroy based on the comment_nid only"
      r = @recommendation2
      finder = {:user_nid => r[:user_nid], :location_nid => r[:location_nid]}
      Comment.destroy_unid_lnid(finder)
      c = Comment.search(finder).first
      c['text'].should == Comment.removed_content_message
    end
    it "should remove a single comment if the nid is specified" do
      pending "should destroy based on the comment_nid only"
      @recommendation1[:text] = 'ttext'
      Comment.create_comment_for_recommendation(@recommendation1)
      (Comment.collection.count - @after).should == 1
      r = @recommendation2
      finder = {:user_nid => r[:user_nid], :location_nid => r[:location_nid]}
      Comment.destroy_unid_lnid(finder)
      Comment.search(finder).first['text'].should == Comment.removed_content_message
    end
  end
  describe "search" do
    before do
      Comment.collection.remove
      # create some comments
      @unid   = Util.ID
      @unid2  = Util.ID
      @lnid   = Util.ID
      @text1 = 'sample text1'
      @text2 = 'example text2'
      @text3 = 'text3 text'
      r = {:location_nid=>@lnid,:user_nid=>@unid,:text=>@text1}
      Comment.create_comment_for_location(r)
      r[:text]=@text2
      Comment.create_comment_for_location(r)
      r[:text]=@text3
      r[:user_nid] =@unid2
      Comment.create_comment_for_location(r)
      @unID = Util.ID
      @lnid2 = Util.ID
      Comment.create_comment_for_location({:user_nid=>@unID,:location_nid=>@lnid2,:text=>'sample text 3'})
    end
    before :each do
      @before= Comment.collection.count
    end
    # for_user_id(unid,options={})
    describe "user" do
      it "should find all comments by a certain user" do
        Comment.for_user_nid(@unid).count.should == 2
      end
      it "should find all comments by multiple users" do
        Comment.for_user_nid(@unid2).count.should == 1
        Comment.for_user_nid(@unID).count.should == 1
      end
    end
    # search_by_unid_lnid(unid,lnid)
    # for_location_nid(lnid,options={})
    describe "location" do
      it "should find the comments about a certain location" do
        Comment.for_location_nid(@lnid).count.should == 3
      end
      it "should find the comments about multiple locations" do
        Comment.for_location_nid(@lnid2).count.should == 1
      end
    end
    # search_by_unid_lnid_rnid(unid,lnid,rnid)
    # for_recommendation_nid(rnid,options={})
    describe "recommendation" do
      before do
        @rnid   = Util.ID
        @rnid2  = Util.ID
        @unid   = Util.ID
        @lnid   = Util.ID
        @text1 = 'sample text1'
        @text2 = 'example text2'
        @text3 = 'text3 text'
        r = {:recommendation_nid=>@rnid,:location_nid=>@lnid,:user_nid=>@unid,:text=>@text1}
        Comment.create_comment_for_location(r)
        r[:text]=@text2
        Comment.create_comment_for_location(r)
        r[:text]=@text3
        r[:recommendation_nid] =@rnid2
        Comment.create_comment_for_location(r)
      end
      it "should find the comments about a certain recommendation" do
        Comment.for_recommendation_nid(@rnid).count.should == 2
      end
      it "should find the comments by multiple recomemndations" do
        Comment.for_recommendation_nid(@rnid2).count.should == 1
      end
    end
  end
end
