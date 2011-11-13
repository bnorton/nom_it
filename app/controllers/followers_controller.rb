class FollowersController < ApplicationController
  
  NUMBER_ARR = /^([0-9]+)(,[0-9]+)*$/  
  
  respond_to :json
  
  before_filter :parse_params,            :only => [:create,:destroy,:followers,:who_follows_nid]
  before_filter :check_params,            :only => [:create,:destroy,:followers,:who_follows_nid]
  before_filter :follow_params,           :only => [:create,:destroy]
  before_filter :authentication_required, :only => [:create,:destroy]
  before_filter :validate_nids,            :only => [:followers,:who_follows_nid]
  
  def create
    follower  = Follower.find_or_create(@nid,@identifier,@items)
    condition = !follower.blank?
    response  = ok_or_not(condition,{:follower=>follower,:follow=>true})
    respond_with response
  end
  
  def destroy
    response = if Follower.unfollow(@nid,@identifier)
      Status.unfollowed
    else
      Status.couldnt_follow_or_unfollow
    end
    respond_with response
  end
  
  # ids of the people who I follow.
  def followers
    nids = Follower.followers_nids(@nid)
    respond_with response_from_nids(nids,:to_user_nid)
  end
  
  # ids of the people who follow some `id`
  def who_follows_nid
    nids = Follower.follows_nid_nids(@nid)
    respond_with response_from_nids(nids,:user_nid)
  end
  
  def response_from_nids(nids,key)
    list = []
    nids.each do |i| 
      list << i[key] 
    end
    list.uniq!
    condition = !list.empty?
    ok_or_not(condition,{:follower=>list,:none=>true})
  end
  
  def ok_or_not(condition,options={})
    if condition && follower = options[:follower] || User.find_by_nid_or_email(@nid)
      Status.OK(follower)
    elsif options[:follow]
      Status.couldnt_follow_or_unfollow
    elsif options[:none]
      Status.no_followers
    else
      Status.user_not_authorized
    end
  end

  
  def parse_params
    @nid    = params[:nid]
    @new   = params[:follower] || params[:other] || params[:new]
    @email = params[:email]
    @fbid  = params[:fbid]
    @twid  = params[:twid]
    @identifier = @new || @email || @fbid || @twid
    @items = {
      :nid   => @new,
      :email=> @email,
      :fbid => @fbid,
      :twid => @twid 
    }
  end
  
  def follow_params
    if @nid.blank? || @identifier.blank?
      respond_with Status.couldnt_follow_or_unfollow
    else

    end
  end
  
  def check_params
    
  end
  
  def validate_nids
    if @nid.blank? || !(@nid =~ NUMBER_ARR)
      respond_with Status.insufficient_arguments
    end
  end

  
  def authentication_required
    
  end
  
end