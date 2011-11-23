class LocationsController < ApplicationController
  
  respond_to :json

  before_filter :lat_lng_user
  before_filter :validate_nids, :only => [:detail] 
  before_filter :authentication_required, :only => [:create]
  before_filter :needs_for_create, :only => [:create]
  before_filter :needs_for_search, :only => [:search,:here]

  DEFAULT_DISTANCE = 0.5

  def here
    search
  end

  def search
    found = Location.search(@geo_opt)
    response = unless found.blank?
      Status.OK(found,{:result_name=>:locations})
    else
      Status.not_found 'locations'
    end
    respond_with response
    
  end

  def detail
    response = if (locations = Location.detail_for_nids(@locations))
      Status.OK(locations,{:result_name=>:locations})
    else
      Status.not_found 'locations'
    end
    respond_with response
  end

  def create
    response = if (loc = Location.create_item(@creation,@optional))
      Status.item_created(loc)
    else
      Status.item_not_created
    end
    respond_with response
  end

  def validate_nids
    if (@locations = params[:location_nids]) =~ NID_LIST
      @locations = @locations.split(',')
    else
      @locations = []
    end
    @location = params[:location_nid]
    @locations << @location if @location =~ NID
    unless @locations.is_a? Array && @locations.length > 0
      respond_with Status.location_not_properly_formatted({ :plural=>true })
    end
  end

  def optional_for_create
    @why = params[:why]
    @optional = {
      :why => @why
    }
  end

  def needs_for_create
    @user_nid = params[:user_nid]
    @auth_token = params[:auth_token]
    @name = params[:name]
    @text = params[:text]
    
    categories
    
    r = nil
    unless (@user_nid && @auth_token)
      r = Status.insufficient_arguments({:message => 'needs acting user and auth_token'})
    end
    unless (@name && @primary)
      r ||= Status.insufficient_arguments({:message => 'needs item name and primary category'})
    end
    respond_with r if r.present?
    
    geolocation_params
    
    @creation = {
      :nid => @nid,
      :auth_token => @auth_token,
      :name => @name,
      :text => @text,
    }
    @categories.merge!(@geolocation)
    @creation.merge!(@categories)
    @categories
  end

  def geolocation_params
    @dist = params[:dist]
    @addr = params[:addr]
    @city = params[:city]
    
    unless (@lat && @lng)
      respond_with Status.insufficient_arguments({:message => 'needs lat/lng or addr/city by default'})
    end
    {
      :lat => @lat,
      :lng => @lng,
      :dist => @dist || DEFAULT_DISTANCE,
      :city => @city,
      :addr => @addr
    }
  end

  def needs_for_search
    @geo_opt = geolocation_params.merge(categories)
  end

  def categories
    @primary = params[:primary]
    @secondary = params[:secondary]
    {
      :primary => @primary,
      :secondary => @secondary
    }
  end

  def authentication_required
    @auth_token = params[:auth_token]
    unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      respond_with Status.user_auth_invalid
    end
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

  
end