class FollowersController < ApplicationController
  
  NUMBER_ARR = /^([0-9]+)(,[0-9]+)*$/  
  
  respond_to :json
  
  before_filter :parse_params,            :only => [:create,:destroy,:followers,:who_follows_id]
  before_filter :check_params,            :only => [:create,:destroy,:followers,:who_follows_id]
  before_filter :follow_params,           :only => [:create,:destroy]
  before_filter :authentication_required, :only => [:create,:destroy]
  before_filter :validate_ids,            :only => [:followers,:who_follows_id]
  
  def create
    follower  = Follower.find_or_create(@id,@identifier,@items)
    condition = !follower.blank?
    response  = ok_or_not(condition,{:follower=>follower,:follow=>true})
    respond_with response
  end
  
  def destroy
    response = if Follower.unfollow(@id,@identifier)
      Status.unfollowed
    else
      Status.couldnt_follow_or_unfollow
    end
    respond_with response
  end
  
  def 
  
  # ids of the people who I follow.
  def followers
    ids = Follower.followers_ids(@id)
    respond_with response_from_ids(ids,:to_user)
  end
  
  # ids of the people who follow some `id`
  def who_follows_id
    ids = Follower.follows_id_ids(@id)
    respond_with response_from_ids(ids,:user)
  end
  
  def response_from_ids(ids,key)
    list = []
    ids.each do |i| 
      list << i[key] 
    end
    list.uniq!
    condition = !list.empty?
    ok_or_not(condition,{:follower=>list,:none=>true})
  end
  
  def ok_or_not(condition,options={})
    if condition && follower = options[:follower] || User.find_by_id_or_email(@id)
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
    @id    = params[:id]
    @new   = params[:follower] || params[:other]
    @email = params[:email]
    @fbid  = params[:fbid]
    @twid  = params[:twid]
    @identifier = @new || @email || @fbid || @twid
    @items = {
      :id   => @new,
      :email=> @email,
      :fbid => @fbid,
      :twid => @twid 
    }
  end
  
  def follow_params
    if @id.blank? || @identifier.blank?
      respond_with Status.couldnt_follow_or_unfollow
    else

    end
  end
  
  def check_params
    
  end
  
  def validate_ids
    if @id.blank? || !(@id =~ NUMBER_ARR)
      respond_with Status.insufficient_arguments
    end
  end

  
  def authentication_required
    
  end
  
end