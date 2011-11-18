class LocationsController < ApplicationController
  
  respond_to :json
  
  before_filter :lat_lng_user
  before_filter :validate_nids, :only => [:detail] 
  before_filter :authentication_required, :only => [:edit,:create]
  before_filter :needs_for_create, :only => [:create]
  before_filter :needs_for_search, :only => [:search,:here]
  
  DEFAULT_DISTANCE = 0.5
  
  def here
    search
  end
  
  def search
    found = Location.search(@geo_opt)
    response = unless found.blank?
      Status.locations(found)
    else
      Status.no_locations_found
    end
    respond_with response
    
  end
  
  def detail
    response = if (locations = Location.detail_for_nids(@locations))
      Status.locations(locations)
    else
      Status.no_locations_found
    end
    respond_with response
  end
  
  # # required
  # @nid
  # @token
  # @name
  # @primary
  # (@lat AND @lng) OR (@addr AND @city)
  # # optional
  # @text
  def create
    response = if (loc = Location.create_item(@creation,@optional))
      Status.item_created(loc)
    else
      Status.item_not_created
    end
    respond_with response
  end
  
  def validate_nids
    @locations  = params[:nids] || []
    @locations << params[:nid]
    @locations = @locations.respond_to?(:split) ? @locations.split(',') : @locations
    flag = false
    unless @locations.is_a?(Array) && @locations.length > 0
      respond_with Status.location_not_properly_formatted({:plural=>true}) if flag
    end
  end
  
  def optional_for_create
    @why = params[:why]
    @optional = {
      :why => @why
    }
  end
  
  def needs_for_create
    @nid = params[:nid]
    @token = params[:token]
    @name = params[:name]
    @text = params[:text]
    
    categories
    
    r = nil
    unless (@nid && @token)
      r = Status.insufficient_arguments({:message => 'needs acting user and auth_token'})
    end
    unless (@name && @primary)
      r ||= Status.insufficient_arguments({:message => 'needs item name and primary category'})
    end
    respond_with r if r.present?
    
    geolocation_params
    
    @creation = {
      :nid => @nid,
      :token => @token,
      :name => @name,
      :text => @text,
    }
    @categories.merge!(@geolocation)
    @creation.merge!(@categories)
    @categories
  end
  
  def geolocation_params
    @lat = params[:lat]
    @lng = params[:lng]
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
    # token from the db must match
  end
  
  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

  
end