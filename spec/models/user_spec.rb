require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "user" do
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
    @third = {
      :name => 'Test User 3',
      :email => '__email@gmail.com',
      :screen_name => 'usertest',
      :password => 'password'
    }
  end
  describe "create" do
    it "should create a new user" do
      email = @brian[:email]
      User.register(email,@brian[:password],@brian[:screen_name])
      user = User.find_by_email(email)
      user.email.should == email
      user.screen_name.should == @brian[:screen_name]
      user.password.should == Digest::SHA2.hexdigest(user[:salt] + @brian[:password])
      user.has_joined.should == true
    end
    it "should create two new users that are the correct details" do
      User.register(@brian[:email],@brian[:password],@brian[:screen_name]).class.should == User
      User.register(@mark[:email], @mark[:password], @mark[:screen_name]).class.should == User
      
      new_brian = User.find_by_email(@brian[:email])
      new_brian.email.should == @brian[:email]
      
      new_mark = User.find_by_email(@mark[:email])
      new_mark.email.should == @mark[:email]
    end
    
    it "should login a user via email or ID after that user been registerd into the system" do
      User.register(@brian[:email],@brian[:password],@brian[:screen_name]).class.should == User
      User.login(@brian[:email],@brian[:password]).should == true
    
      brian = User.find_by_email(@brian[:email])
      User.login(brian.id, @brian[:password]).should == true
    end
  end
  describe "searching" do
    before :each do
      @brian_id = User.register(@brian[:email],@brian[:password],@brian[:screen_name]).id
      @mark_id  = User.register(@mark[:email], @mark[:password], @mark[:screen_name] ).id
      @third_id = User.register(@third[:email],@third[:password],@third[:screen_name]).id
    end
    
    it "should find the users by id" do
      User.find_by_any_means_necessary(@brian_id).should_not be_blank
      User.find_by_any_means_necessary(@mark_id).should_not be_blank
      User.find_by_any_means_necessary(@third_id).should_not be_blank
    end
    it "should find the users by email" do
      User.find_by_any_means_necessary(@brian[:email]).should_not be_blank
      User.find_by_any_means_necessary(@mark[:email]).should_not be_blank
      User.find_by_any_means_necessary(@third[:email]).should_not be_blank
    end
    it "should find the users by screen_name" do
      User.find_by_any_means_necessary(@brian[:screen_name]).should_not be_blank
      User.find_by_any_means_necessary(@mark[:screen_name]).should_not be_blank
      User.find_by_any_means_necessary(@third[:screen_name]).should_not be_blank
    end
  end
    
  describe "should join later" do
    before do
      @brian_FACEBOOK = {
        'email' => 'brian_FB_email@gmail.com',
        'id'    => 1234,
        'name'  => 'brian fb name'
      }
    end
    before :each do
      @local_brian = @brian.merge({:fbid => 1234, :twid => 4321})
      @should_join_brian = User.create_should_join(@local_brian)
    end
    it "should find a user that has been created but has not actually registered via EMAIL" do
      @should_join_brian.has_joined.should == false
      
      # create the user later based on criteria
      actually_reg = User.register(@brian[:email],@brian[:password],@brian[:screen_name])
      actually_reg.should_not be_blank
      actually_reg.has_joined.should == true
    end
    it "should find a user that has been created but has not actually registered via FACEBOOK" do
      @should_join_brian.has_joined.should == false
      
      # create the user later based on criteria
      User.register_with_facebook(@brian_FACEBOOK).should == true
      found = User.find_by_facebook(@brian_FACEBOOK['id'])
      found.should_not be_blank
    end
    it "should find a user that has been created but has not actually registered via TWITTER" do
      @should_join_brian.has_joined.should == false
      
      # create the user later based on criteria
      actually_reg = User.register(@brian[:email],@brian[:password],@brian[:screen_name])
      actually_reg.should_not be_blank
      actually_reg.has_joined.should == true
    end
  end
end
