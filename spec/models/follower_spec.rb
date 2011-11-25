require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "follower" do
  before do
    @brian = {
      :name => 'Brian Norton',
      :email => '__brian.nort@gmail.com',
      :screen_name => 'nort',
      :password => 'password'
    }
    @mark = {
      :name => 'Mark Parker',
      :email => '__parker.mark@gmail.com',
      :screen_name => 'parkermark',
      :password => 'password'
    }
  end
  describe "create" do
    before :each do
      User.register(@brian[:email],@brian[:password],@brian[:screen_name])
      @brian_nid = User.find_by_email(@brian[:email]).nid
      User.register(@mark[:email], @mark[:password],@mark[:screen_name])
      @mark_nid  = User.find_by_email(@mark[:email]).nid
    end
    it "should create a new follow relationship based on ID" do
      Follower.find_or_create(@brian_nid,@mark_nid,@mark)
      fbrian = Follower.find_by_user_nid(@brian_nid)
      fbrian.to_user_nid.should == @mark_nid
      
      fmark  = Follower.find_by_user_nid(@mark_nid)
      fmark.should be_blank
    end
    it "should create the inverse follow relationship" do
      Follower.find_or_create(@brian_nid,@mark_nid,@mark)
      fbrian = Follower.find_by_user_nid(@brian_nid)
      Follower.find_or_create(@mark_nid,@brian_nid,@brian)
      fmark  = Follower.find_by_user_nid(@mark_nid)
      fbrian.should_not be_blank
      fbrian.to_user_nid.should == @mark_nid
      fmark.should_not be_blank
      fmark.to_user_nid.should == @brian_nid
    end
    it "should be undirected if both users follow each other" do
    end
  end
  describe "not joined" do
    before :each do
      User.register(@brian[:email],@brian[:password],@brian[:screen_name])
      @brian_nid = User.find_by_email(@brian[:email]).nid
      @random_email = 'some_random_email@gmail.com'
      Follower.find_or_create(@brian_nid,@random_email,{:email => @random_email})
    end
    it "should make an unjoined user to point to when the followed user has not registered" do
      brian = User.find_by_email(@brian[:email])
      newu   = User.find_by_email(@random_email)
      
      brian.should_not be_blank
      brian.has_joined.should == true
      
      newu.should_not be_blank
      newu.has_joined.should == false
    end
    it "should find an unjoined user when said use actually registers sometime later via EMAIL" do
      newu   = User.find_by_email(@random_email)
      newu.should_not be_blank
      newu.has_joined.should == false
      
      User.register(@random_email,'password','random')
      newu   = User.find_by_email(@random_email)
      newu.should_not be_blank
      newu.has_joined.should == true  # shoud now have joined
    end
    it "should find an unjoined user when said use actually registers sometime later via FACEBOOK ID" do
      _FBID = 12345
      newu   = User.find_by_email(@random_email)
      newu.facebook = _FBID
      newu.save
      fbuser = User.find_by_facebook(_FBID)
      fbuser.should_not be_blank
      fbuser.has_joined.should == false
      
      fb_user = {
        'email' => 'brian_FB_email@gmail.com',
        'id'    => _FBID,
        'name'  => 'brian fb name'
      }
      User.register_with_facebook(fb_user)
      fbuser = User.find_by_facebook(_FBID)
      fbuser.should_not be_blank
      fbuser.has_joined.should == true
    end
    after do
      User.find_by_email(@brian[:email]).destroy
    end
  end
  describe "followers listing" do
    before do
      User.register(@brian[:email],@brian[:password],@brian[:screen_name])
      @one = User.find_by_email(@brian[:email])
      User.register(@mark[:email],@mark[:password],@mark[:screen_name])
      @two = User.find_by_email(@mark[:email])
      User.register('some_other_email@gmail.com','password','samplename')
      @thr = User.find_by_email('some_other_email@gmail.com')
    end
    it "should find followers that have followed a user" do
      Follower.find_or_create(@one.nid,@two.nid,@mark)
      ones_followers = Follower.following(@one.nid)
      ones_followers.length.should == 1
      Follower.find_or_create(@one.nid,@thr.nid,@brian)
      @ones_followers = Follower.following(@one.nid)
      @ones_followers.length.should == 2
      valid, i = [], 0
      while i < @ones_followers.length
        o = @ones_followers[i]
        if o.user_nid == @two.nid
          valid << true
        elsif o.user_nid == @thr.nid
          valid << true
        end
        i += 1
      end
      valid.length.should == 2
      valid[0].should == true
      valid[1].should == true
      
      # users that follow me should not have followers
      twos_followers = Follower.following(@two.nid)
      twos_followers.length.should == 0
      
      thrs_followers = Follower.following(@thr.nid)
      thrs_followers.length.should == 0
    end
    it "should find followers that a user follows" do
      Follower.find_or_create(@two.nid,@one.nid,@mark)
      Follower.find_or_create(@two.nid,@thr.nid,@brian)
      
      Follower.following(@two.nid).length.should == 2
      Follower.followers(@one.nid).length.should == 1
      Follower.followers(@thr.nid).length.should == 1
    end
    it "should not find users that have not yet joined" do
      sR = 'some_random_email2@gmail.com'
      Follower.find_or_create(@two.nid,sR,{:screen_name=>'random_user',:email=>sR})
      
      some = User.find_by_email('some_random_email2@gmail.com')
      some.should_not be_blank
      some.has_joined.should == false
      
      Follower.following(@two.nid).length.should  == 0
      Follower.followers(@two.nid).length.should == 0
    end
    it "should find users that were not joined and that are now members" do
      sR = 'some_random_email2@gmail.com'
      random_user = {:screen_name=>'random_user',:email=>sR}
      Follower.find_or_create(@two.nid,random_user[:email],random_user)
      Follower.following(@two.nid).length.should  == 0
      Follower.followers(@two.nid).length.should == 0
      
      User.register(random_user[:email],'password',random_user[:screen_name])
      Follower.following(@two.nid).length.should  == 1
      Follower.followers(@two.nid).length.should == 0
    end
    after do
      @one.destroy
      @two.destroy
      @thr.destroy
    end
  end
  describe "unfollow" do
    it "should unfollow a user" do
      
    end
    it "should not list users that were unfollowed" do
      
    end
    it "should not remove that user record when unfollowed" do
      
    end
  end
  describe "block" do
    it "should block users" do
      
    end
    it "should not list users that were blocked" do
      
    end
  end
end
