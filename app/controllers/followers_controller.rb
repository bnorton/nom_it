class FollowersController < ApplicationController

  NUMBER_ARR = /^([0-9]+)(,[0-9]+)*$/

  respond_to :json

  before_filter :lat_lng_user
  before_filter :parse_params
  before_filter :check_params,            :only => [:create,:destroy,:followers,:following]
  before_filter :followers_params,        :only => [:create,:destroy]
  before_filter :following_params,        :only => [:followers,:following]
  before_filter :authentication_required, :only => [:create,:destroy]
  before_filter :validate_nids,           :only => [:followers,:followers]

  def create
    follower  = Follower.find_or_create(@user_nid,@identifier,@items)
    condition = !follower.blank?
    response  = ok_or_not(condition,{:follower=>follower,:follow=>true})
    respond_with response
  end

  def destroy
    response = if Follower.unfollow(@user_nid,@identifier)
      Status.unfollowed
    else
      Status.couldnt_follow_or_unfollow
    end
    respond_with response
  end

  def followers
    nids = Follower.followers(@user_nid)
    respond_with response_from_nids(nids,:to_user_nid)
  end

  def following
    nids = Follower.following(@user_nid)
    respond_with response_from_nids(nids,:user_nid)
  end
  
  private
  
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
    if condition && follower = options[:follower] || User.find_by_nid_or_email(@user_nid)
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
    @to_user_nid = params[:to_user_nid] || params[:new]
    @email = params[:email]
    @fbid = params[:fbid]
    @twid = params[:twid]
    @identifier = @to_user_nid || @email || @fbid || @twid
    @items = {
      :to_user_nid   => @to_user_nid,
      :email=> @email,
      :fbid => @fbid,
      :twid => @twid 
    }
  end

  def followers_params
    if @user_nid.blank? || @identifier.blank?
      respond_with Status.couldnt_follow_or_unfollow
    end
  end

  def validate_nids
    if @user_nid.blank? || !(@user_nid =~ NUMBER_ARR)
      respond_with Status.insufficient_arguments
    end
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

  def authentication_required
    
  end
  
end