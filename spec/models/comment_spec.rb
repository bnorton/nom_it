require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "comments" do
  describe "input validations" do
    before do
      Comment.collection.remove
      @txtfail1 = {:uid => 32, :lid => 23}
      @txtfail2 = {:uid => 32, :lid => 23, :rid => 55}
      @locfail1 = {:uid => 32, :text => 'sample'}
      @locfail2 = {:lid => 23, :text => 'sample'}
      @recfail1 = @locfail1.merge({:lid => 23})
      @recfail2 = @locfail2.merge({:uid => 32})
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
    it "should reject a location comment of the lid and uid are not specified" do
      Comment.create_comment_for_location(@locfail1).should == false
      Comment.create_comment_for_location(@locfail2).should == false
    end
    it "should reject a recommendation comment of the rid, lid and uid are not specified" do
      Comment.create_comment_for_recommendation(@recfail1).should == false
      Comment.create_comment_for_recommendation(@recfail2).should == false
    end
    it "should reject a new comment if it doesnt at least have a nid" do
      Comment.create_comment_for_recommendation(@nidfail).should == false
      Comment.create_comment_for_location(@nidfail).should == false
    end
    it "should reject a search if none of the correct parameters are not specified" do
      
    end
    it "should reject a new comment for nid without an nid" do
      Comment.create_comment_for_nid({:text=>"some failure"}).should == false
    end
    it "should not find any items that match any of the query items from this run" do
      
    end
  end
  describe "create" do
    before do
      Comment.collection.remove
    end
    # create_comment_for_location(options) => must include lid, uid, text
    describe "location" do
      before do
        @location1 = {:lid=>10,:uid=>1,:text=>'sample comment'  }
        @location2 = {:lid=>10,:uid=>3,:text=>'sample comment2' }
        @location3 = {:lid=>12,:uid=>5,:text=>'sample comment17'}
        @location4 = {:lid=>12,:uid=>7,:text=>'sample comment23'}
      end
      before :each do
        @before = Comment.collection.size
      end
      it "should create a new comment for a location" do
        Comment.create_comment_for_location(@location1).class.should == BSON::ObjectId
        (Comment.collection.count - @before).should == 1
      end
      it "should create multiple comments for various locations" do
        Comment.create_comment_for_location(@location1).class.should == BSON::ObjectId
        Comment.create_comment_for_location(@location2).class.should == BSON::ObjectId
        (Comment.collection.count - @before).should == 2
        
        Comment.create_comment_for_location(@location3).class.should == BSON::ObjectId
        Comment.create_comment_for_location(@location4).class.should == BSON::ObjectId
        (Comment.collection.count - @before).should == 4
      end
      it "should then find the created comments based on the criteria" do
        
      end
    end
    # create_comment_for_recommendation (option) => must include rid, lid, uid, text
    describe "recommendations" do
      before do
        @recommendation1 = {:rid=>2,:lid=>10,:uid=>1,:text=>'sample comment'}
        @recommendation2 = {:rid=>2,:lid=>10,:uid=>3,:text=>'sample comment2 from user 3'}
        @recommendation3 = {:rid=>2,:lid=>10,:uid=>5,:text=>'sample comment17'}
        @recommendation4 = {:rid=>7,:lid=>12,:uid=>7,:text=>'sample comment23'}
        @oid = BSON::ObjectId.new.to_s
        @recommendation_nid = {:nid=>@oid,:text=>"sample with a nid how about that"}
      end
      before :each do
        @before = Comment.collection.count
      end
      it "should create a new comment for a recommendation" do
        Comment.create_comment_for_recommendation(@recommendation1).class.should == BSON::ObjectId
        (Comment.collection.count - @before).should == 1
      end
      it "should create a few new comments for a single recommendation" do
        Comment.create_comment_for_recommendation(@recommendation1).class.should == BSON::ObjectId
        Comment.create_comment_for_recommendation(@recommendation2).class.should == BSON::ObjectId
        Comment.create_comment_for_recommendation(@recommendation3).class.should == BSON::ObjectId
        (Comment.collection.count - @before).should == 3
      end
      it "should create a comment for the specified nid" do
        Comment.create_comment_for_nid(@recommendation_nid).class.should == BSON::ObjectId
        (Comment.collection.count - @before).should == 1
      end
      it "should then find the created items based on the search criteria" do
        
      end
    end
  end
  # destroy(opt={})
  #   return false unless Comment.check_params(opt)
  # 
  # destroy_id(id)
  describe "destroy" do
    before do
      Comment.collection.remove
      @recommendation1 = {:rid=>2,:lid=>10,:uid=>1,:text=>'sample comment'}
      @recommendation2 = {:rid=>2,:lid=>10,:uid=>3,:text=>'sample comment2 from user 3'}
    end
    before :each do
      @before = Comment.collection.count
      @id1 = Comment.create_comment_for_recommendation(@recommendation1)
      @id2 = Comment.create_comment_for_recommendation(@recommendation2)
      @after = Comment.collection.count
      (@after - @before).should == 2
    end
    it "should remove any comemnts that were specified for delete" do
      Comment.destroy_id(@id1.to_s)
      Comment.destroy_id(@id2.to_s)
      (Comment.collection.count - @after).should == 0
    end
    it "should remove all comments that match the uid, lid (all of a users comments about a location)" do
      r = @recommendation1
      finder = {:uid => r[:uid], :lid => r[:lid]}
      Comment.destroy(finder)
      (Comment.collection.count - @after).should == 0
      comment = Comment.search_by_uid_lid(r[:uid],r[:lid]).first
      comment['text'].should == Comment.removed_content_message
      
      r = @recommendation2
      finder = {:uid => r[:uid], :lid => r[:lid]}
      Comment.destroy(finder)
      (Comment.collection.count - @after).should == 0
      comment = Comment.search_by_uid_lid(r[:uid],r[:lid]).first
      comment['text'].should == Comment.removed_content_message
    end
    it "should remove all comments that match the rid, uid, lid (all of a users comments about a location)" do
      r = @recommendation1
      Comment.destroy({:rid => r[:rid], :uid => r[:uid], :lid => r[:lid]})
      (Comment.collection.count - @after).should == 0
      
      r = @recommendation2
      Comment.destroy({:rid => r[:rid], :uid => r[:uid], :lid => r[:lid]})
      (Comment.collection.count - @after).should == 0
    end
    it "should have the common verbage for a deleted comment with user data still attached" do
      msg = Comment.removed_content_message
      
    end
    it "should remove a single comment if the nid is specified" do
      
    end
  end
  describe "search" do
    before do
      Comment.collection.remove
      # create some comments
      @uid   = rand(1<<8)
      @uid2  = rand(1<<8)
      @lid   = rand(1<<8)
      @text1 = 'sample text1'
      @text2 = 'example text2'
      @text3 = 'text3 text'
      r = {:lid=>@lid,:uid=>@uid,:text=>@text1}
      Comment.create_comment_for_location(r)
      r[:text]=@text2
      Comment.create_comment_for_location(r)
      r[:text]=@text3
      r[:uid] =@uid2
      Comment.create_comment_for_location(r)
      @uID = 99
      Comment.create_comment_for_location({:uid=>@uID,:lid=>12,:text=>'sample text 3'})
    end
    before :each do
      @before= Comment.collection.count
    end
    # for_user_id(uid,options={})
    describe "user" do
      it "should find all comments by a certain user" do
        Comment.for_user_id(@uid).count.should == 2
      end
      it "should find all comments by multiple users" do
        Comment.for_user_id(@uid2).count.should == 1
        Comment.for_user_id(@uID).count.should == 1
      end
    end
    # search_by_uid_lid(uid,lid)
    # for_location_id(lid,options={})
    describe "location" do
      it "should find the comments about a certain location" do
        Comment.for_location_id(@lid).count.should == 3
      end
      it "should find the comments about multiple locations" do
        Comment.for_location_id(12).count.should == 1
      end
    end
    # search_by_uid_lid_rid(uid,lid,rid)
    # for_recommendation_id(rid,options={})
    describe "recommendation" do
      before do
        @rid   = rand(1<<8)
        @rid2  = rand(1<<8)
        @uid   = 8
        @lid   = rand(1<<8)
        @text1 = 'sample text1'
        @text2 = 'example text2'
        @text3 = 'text3 text'
        r = {:rid=>@rid,:lid=>@lid,:uid=>@uid,:text=>@text1}
        Comment.create_comment_for_location(r)
        r[:text]=@text2
        Comment.create_comment_for_location(r)
        r[:text]=@text3
        r[:rid] =@rid2
        Comment.create_comment_for_location(r)
      end
      it "should find the comments about a certain recommendation" do
        Comment.for_recommendation_id(@rid).count.should == 2
      end
      it "should find the comments by multiple recomemndations" do
        Comment.for_recommendation_id(@rid2).count.should == 1
      end
    end
  end
end
