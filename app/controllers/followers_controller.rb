class FollowersController < ApplicationController
  
  NUMBER_ARR = /^([0-9a-zA-Z]+)(,[0-9a-zA-Z]+)*$/

  respond_to :json

  before_filter :lat_lng_user
  before_filter :parse_params
  before_filter :followers_params,        :only => [:create,:destroy]
  before_filter :authentication_required, :only => [:create,:destroy]
  before_filter :validate_nids

  def create
    response = if (follower = Follower.find_or_create(@user_nid,@identifier,@items))
      Status.follow_list(follower, {:result_name => :followers})
    else
      Status.item_not_created 'follower'
    end
    respond_with response
  end

  def destroy
    response = if Follower.unfollow(@user_nid,@identifier)
      Status.unfollowed
    else
      Status.item_not_destroyed 'follower'
    end
    respond_with response
  end

  def followers
    followers = Follower.followers(@user_nid)
    respond_with Status.follow_list(followers, {:result_name => :followers})
  end

  def following
    following = Follower.following(@user_nid)
    respond_with Status.follow_list(following, {:result_name => :following})
  end

  def followers_list
    nids = Follower.followers_nids(@user_nid)
    respond_with Status.follow_list(nids, {:result_name => :followers})
  end

  def following_list
    nids = Follower.following_nids(@user_nid)
    respond_with Status.follow_list(nids, {:result_name => :following})
  end

  private

  def parse_params
    @to_user_nid = params[:to_user_nid]
    @email = params[:email]
    @fbid = params[:fbid]
    @twid = params[:twid]
    @identifier = @to_user_nid || @email || @fbid || @twid
    @items = {
      :to_user_nid => @to_user_nid,
      :email=> @email,
      :fbid => @fbid,
      :twid => @twid 
    }
  end

  def followers_params
    if @user_nid.blank? || @identifier.blank?
      respond_with Status.item_not_destroyed 'follower'
    end
  end

  def validate_nids
    if @user_nid.blank? || !(@user_nid =~ NID_LIST)
      respond_with Status.insufficient_arguments
    end
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

  def authentication_required
    @auth_token = params[:auth_token]
    unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      respond_with Status.user_auth_invalid
    end
  end
  
end