class RecommendationsController < ApplicationController
  DOUBLE = /[\d]+.[\d]+/
  
  respond_to :json
  
  before_filter :required_for_creation,  :only => [:create ]
  before_filter :required_for_destroy,   :only => [:destroy]
  before_filter :required_for_update,    :only => [:update ]
  before_filter :optional,               :only => [:create,:update]
  before_filter :user_or_location,       :only => [:create,:user,:location]
  before_filter :authentication_required,:only => [:user,:location]
  
  def create
    token,item = Recommendation.create(@all_params)
    followers  = Follower.users_that_follow_me(@user)
    recommends = Recommend.create(item,followers)
    condition  = !token.blank? && recommends
    respond_with ok_or_not(condition,{
      :token  =>token,
      :action =>'create'})
  end
  
  def destroy
    Recommendation.destroy()
    respond_with ok_or_not(condition,{:action=>'destroy'})
  end
  
  def update
    
  end
  
  def user
    wrapper(Recommendation.for_user(@user),
             {:empty => "user"})
  end
  
  def location
     wrapper(Recommendation.for_location(@user),
             {:empty => "location"})
  end
  
  def wrapper(recommendations,options={})
    condition = !recommendations.blank?
    respond_with ok_or_not(condition,{
      :recommends =>recommendations,
      :action     =>'lookup',}.merge(options))
  end
  
  def ok_or_not(condition,options={})
    if condition
      if token = options[:token]
        Status.TOKEN(token)
      elsif recommends = options[:recommends]
        Status.OK(recommends)
      else
        STATUS.OK
      end
    elsif options[:empty]
      Status.no_recommendations
    else
      Status.couldnt_complete_recommendation options[:action]
    end
  end

  
  def required_for_creation
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user = params[:user]
    @location = params[:location]
    if (@lat.blank? || @lng.blank? || @user.blank? || @location.blank?)
      respond_with Status.recommendation_not({:word => "made"})
    end
  end
  
  def required_for_destroy
    @recid = params[:id]  || params[:recommendation]
    @user  = params[:uid] || params[:user]
    if @recid.blank? || @user.blank?
      respond_with Status.recommendation_not({:word => "destroyed"})
    end
  end
  
  def required_for_update
    required_for_destroy
    @text = params[:text]
    if @text.blank?
      respond_with Status.recommendation_not({:word => "updated"})
    end
  end
  
  def user_or_location
    @user = params[:user] || params[:uid]
    if @user.blank?
      respond_with Status.no_recommendations
    end
  end
  
  def optional
    @text     = params[:text]
    @title    = params[:title]
    @name     = params[:name]
    @user_name= params[:user_name]
    @city     = params[:city]
    @facebook = params[:facebook]
    @twitter  = params[:twitter]
    all_params_hash
  end
  
  def all_params_hash
    @all_params = {
      :lat  => @lat,
      :lng  => @lng,
      :user => @user,
      :text => @text,
      :location => @location,
      ## optional
      :title => @title,
      :name  => @name,
      :user_name=> @user_name,
      :city  => @city,
      :facebook => @facebook,
      :twitter  => @twitter
    }
  end
  
  def authentication_required
    
  end
  
end
