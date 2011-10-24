class FollowersController < ApplicationController
  
  respond_to :json
  
  before_filter :parse_params,            :only => [:follow,:followers,:follows_me]
  before_filter :check_params,            :only => [:follow,:followers,:follows_me]
  before_filter :authentication_required, :only => [:follow,:follows_me]
  
  def follow
    follow_params
    follower  = Follower.find_or_create(@id,@identifier,@items)
    condition = !follower.blank?
    response  = ok_or_not(condition,{:follower=>follower,:follow=>true})
    respond_with response
  end
  
  def followers
    ids = Follower.followers_ids(@id)
    list = []; ids.each do |id| list << id[:follower] end
    condition = !list.empty?
    response  = ok_or_not(condition,{:follower=>list,:none=>true})
    respond_with response
  end
  
  def follows_me
    
  end
  
  def ok_or_not(condition,options={})
    if condition && follower = options[:follower] || User.find_by_id_or_email(@id)
      Status.OK(follower)
    elsif options[:follow]
      Status.couldnt_follow
    elsif options[:none]
      Status.no_followers
    else
      Status.user_not_authorized
    end
  end

  
  def parse_params
    @id    = params[:id]
    @new   = params[:follower]
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
      respond_with Status.couldnt_follow
    end
  end
  
  def check_params
    
  end
  
  def authentication_required
    
  end
  
end