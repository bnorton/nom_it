require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# check
# me
# register
# login
# detail
# search
# thumb_create
# thumbs
# thumbed

describe UsersController do
  before do
    @ok_status = 1
    @nort = { :name => 'brian norton', :screen_name => 'nort', :email => 'sample1@email.com', :password => 'password'}
    @shanfor = { :name => 'shannon forbes', :screen_name => 'shanfor', :email => 'sample2@email.com', :password => 'password'}
  end
  describe "#check" do
    it "should check the name of the a user" do
      get(:check, :format => :json, :screen_name => @nort[:screen_name])
      JSON.parse(response.body)['status'].should == 1
    end
    it "should tell you when the name is already taken" do
      get(:check, :format => :json, :screen_name => @nort[:screen_name])
      JSON.parse(response.body)['status'].should == 1  ### YES
      get(:register, :format => :json, :email => @nort[:email], :password => @nort[:password], :screen_name => @nort[:screen_name])
      get(:check, :format => :json, :screen_name => @nort[:screen_name])
      JSON.parse(response.body)['status'].should == -1 ### NO
    end
    it "should reserve for X minutes when the name is not taken" do
      pending
    end
  end
  describe "#me" do
    before :each do
      get(:register, :format => :json, :email => @nort[:email], :password => @nort[:password], :screen_name => @nort[:screen_name])
      @auth_token = JSON.parse(response.body)['results'][0]['auth_token']
    end
    it "should find the user that is currently authed for that auth_token" do
      pending
      get(:me, :format => :json, :auth_token => @auth_token)
      body = JSON.parse(response.body)
      body['status'].should == 1
      body['results'][0]['screen_name'].should == @nort[:screen_name]
    end
    it "should ask the user to auth if he/she is not valid for the token" do
      pending
    end
  end
  describe "#register" do
    it "should regiter users through nom" do
      get(:register, :format => :json, :email => @nort[:email], :password => @nort[:password], :screen_name => @nort[:screen_name])
      body = JSON.parse(response.body)
      body['status'].should == @ok_status
      body['results'][0]['user_nid'].should_not be_blank
    end
    it "should register a user from FACEBOOK" do
      pending
    end
    it "should register a user from TWITTER" do
      pending
    end
  end
  describe "#login" do
    before do
      get(:register, :format => :json, :email => @nort[:email], :password => @nort[:password], :screen_name => @nort[:screen_name])
      JSON.parse(response.body)['results'][0]['auth_token'].should_not be_blank
      get(:register, :format => :json, :email => @shanfor[:email], :password => @shanfor[:password], :screen_name => @shanfor[:screen_name])
    end
    it "should login a newly registered user" do
      JSON.parse(response.body)['results'][0]['auth_token'].should_not be_blank
    end
    it "should login a user" do
      get(:search, :format => :json, :q => @nort[:email])
      nid = JSON.parse(response.body)['results'][0]['user_nid']
      get(:login, :format => :json, :user_nid => nid, :password => @nort[:password])
      JSON.parse(response.body)['status'].should == 1
    end
  end
  describe "#search" do
    before do
      get(:register, :format => :json, :email => @nort[:email], :password => @nort[:password], :screen_name => @nort[:screen_name], :name => @nort[:name])
      JSON.parse(response.body)['results'][0]['auth_token'].should_not be_blank
    end
    it "should find a user by email" do
      get(:search, :format => :json, :email => @nort[:email])
    end
    it "should find a user by screen_name" do
      get(:search, :format => :json, :screen_name => @nort[:screen_name])
    end
    it "should find a user by name" do
      get(:search, :format => :json, :q => @nort[:name])
    end
    it "should find a user by something like a name" do
      get(:search, :format => :json, :q => @nort[:name][6..11])
    end
    after :each do
      body = JSON.parse(response.body)
      body['status'].should == 1
      body['results'][0]['screen_name'].should == @nort[:screen_name]
    end
    after do
      User.find_by_email(@nort[:email]).destroy
    end
  end
  describe "#detail" do
    it "should find the location"
  end
end