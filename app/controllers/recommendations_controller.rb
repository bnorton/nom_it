class RecommendationsController < ApplicationController
  
  DOUBLE = /[\d]+.[\d]+/

  respond_to :json
  
  before_filter :required_for_creation,  :only => [:create ]
  before_filter :required_for_destroy,   :only => [:destroy]
  before_filter :required_for_update,    :only => [:update ]
  before_filter :optional,               :only => [:create,:update]
  before_filter :user_or_location,       :only => [:create,:user,:location]
  before_filter :id_only,                :only => [:comments,:to_user,:about_location]
  before_filter :authentication_required,:only => [:user,:location]
  
  def create
    token,item = Recommendation.create(@all_params)
    followers  = Follower.users_that_follow_me(@user)
    recommends = Recommend.create(item,followers)
    condition  = !token.blank?
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
  
  # the recommendations made by some user
  def user
    recommendations 'user'
  end
  
  # the recommendations made about some location
  def location
     recommendations 'location'
  end
  
  def to_user
    recommend 'user'
  end
  
  def about_location
    recommend 'location'
  end
  
  private
  
  def recommendations(method_name)
    recs = Recommendation.send("for_#{method_name}".to_sym, @user)
    recs = Util.prepare(recs)
    condition = !recs.blank?
    respond_with ok_or_not(condition,{
      :recommends => recs,
      :action     =>'lookup',
      :empty      => method_name })
  end
  
  def recommend(method_name)
    recs = Recommend.send("for_#{method_name}_nid".to_sym, @nid)
    recs = Util.prepare(recs)
    respond_with ok_or_not(!recs.blank?,{:recommends=>recs})
  end
  
  def ok_or_not(condition,options={})
    if condition
      if token = options[:token]
        Status.TOKEN(token)
      elsif recommends = options[:recommends]
        Status.OK(recommends,options)
      else
        Status.OK
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
    @user = params[:user_nid]
    @location_nid = params[:location_nid]
    if (@lat.blank? || @lng.blank? || @user.blank? || @location_nid.blank?)
      respond_with Status.recommendation_not({:word => "made"})
    end
  end
  
  def required_for_destroy
    @recid = params[:nid] || params[:recommendation]
    @user  = params[:user_nid]
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
    @user = params[:user_nid] || params[:uid]
    if @user.blank?
      respond_with Status.no_recommendations
    end
  end
  
  def id_only
    @nid = params[:nid]
    respond_with Status.comments_not_found if @nid.blank?
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
      :user_nid => @user,
      :text => @text,
      :location_nid => @location_nid,
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
