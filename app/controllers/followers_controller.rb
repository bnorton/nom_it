class FollowersController < ApplicationController
  
  respond_to :json
  
  before_filter :parse_params,            :only => [:follow,:followers,:follows_me]
  before_filter :authentication_required, :only => [:follow,:follows_me]
  
  def follow
    puts "WHAT IS HAD id:#{@id}, identifier: #{@identifier}, items: #{@items}"
    follower  = Follower.find_or_create(@id,@identifier,@items)
    condition = !follower.try(:empty?) && !follower.blank?
    puts "DID WE FIND ONE? #{follower.inspect} and condition #{condition}"
    response  = ok_or_not(condition,{:follower=>follower,:follow=>true})
    respond_with response
  end
  
  def followers
    
  end
  
  def follows_me
    
  end
  
  def ok_or_not(condition,options={})
    if condition && follower = options[:follower] || User.find_by_id_or_email(@id)
      Status.OK(follower)
    elsif options[:follow]
      Status.couldnt_follow
    else
      Status.user_not_authorized
    end
  end

  
  def parse_params
    @id    = params[:id]
    @new   = params[:new]
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
  
  def authentication_required
    
  end
  
end