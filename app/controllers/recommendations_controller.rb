class RecommendationsController < ApplicationController
  
  respond_to :json

  before_filter :lat_lng_user
  before_filter :required_for_creation,  :only => [:create ]
  before_filter :required_for_destroy,   :only => [:destroy]
  before_filter :required_for_update,    :only => [:update ]
  before_filter :optional,               :only => [:create,:update]
  before_filter :user_or_location,       :only => [:create,:user,:location]
  before_filter :id_only,                :only => [:to_user,:about_location]
  before_filter :authentication_required,:only => [:user,:location]

  def create
    item = Recommendation.create(@all_params)
    followers  = Follower.followers_nids(@user_nid)
    recommends = Recommend.create(item,followers)
    respond_with ok_or_not(item.token.present?,{
      :token => item.token}), :location => nil
  end

  def destroy
    raise 'Unimplemented'
  end

  def update
    raise 'Unimplemented'
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
    recs = Recommendation.send(:"for_#{method_name}", @user_nid)
    recs = Util.prepare(recs)
    respond_with ok_or_not(recs.present?,{
      :recommends => recs,
      :empty      => true })
  end

  def recommend(method_name)
    recs = Recommend.send(:"for_#{method_name}_nid", @recommendation_nid)
    recs = Util.prepare(recs)
    respond_with ok_or_not(recs.present?,{:recommends=>recs})
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
      Status.not_found 'recommendations'
    else
      Status.item_not_created 'recommendation'
    end
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

  def required_for_creation
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
    @location_nid = params[:location_nid]
    if (@lat.blank? || @lng.blank? || @user_nid.blank? || @location_nid.blank?)
      respond_with Status.item_not_created('recommendation'), :location => nil
    end
  end

  def required_for_destroy
    @recommendation_nid = params[:recommendation_nid]
    @user_nid  = params[:user_nid]
    if @recommendation_nid.blank? || @user_nid.blank?
      respond_with Status.item_not_destroyed 'recommendation', :location => nil
    end
  end

  def required_for_update
    required_for_destroy
    @text = params[:text]
    if @text.blank?
      respond_with Status.item_not_created 'recommendation'
    end
  end

  def user_or_location
    @user_nid = params[:user_nid]
    if @user_nid.blank?
      respond_with Status.not_found 'recommendation'
    end
  end

  def id_only
    @recommendation_nid = params[:recommendation_nid]
    respond_with Status.not_found 'recommendation' if @recommendation_nid.blank?
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
      :user_nid => @user_nid,
      :text => @text,
      :location_nid => @location_nid,
      :token => params[:token],
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
    @auth_token = params[:auth_token]
    unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      respond_with Status.user_auth_invalid
    end
  end

end
