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
    found,dist = Location.search(@geo_opt,@start,@limit)
    response = unless found.blank?
      Status.SEARCHED(found,dist)
    else
      Status.not_found 'locations'
    end
    respond_with response
    
  end

  def detail
    response = if (locations = Location.detail_for_nids(@location_nids))
      Status.OK(locations)
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
    respond_with response, :location => nil
  end

  def validate_nids
    @location_nid = params[:location_nid]
    @location_nids = params[:location_nids] || ''
    if @location_nids.present?
      @location_nids << ",#{@location_nid}" if @location_nid.present?
    else
      @location_nids << @location_nid if @location_nid.present?
    end
    if @location_nids.blank? || !(@location_nids =~ NID_LIST)
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
      r ||= Status.insufficient_arguments({:message => 'needs acting user and auth_token'})
    end
    unless (@name && @primary)
      r ||= Status.insufficient_arguments({:message => 'needs item name and primary category'})
    end
    respond_with(r, :location => nil) if r.present?

    geolocation_params

    @creation = {
      :user_nid => @user_nid,
      :auth_token => @auth_token,
      :name => @name,
      :text => @text,
    }
    @categories.merge!(@geolocation)
    @creation.merge!(@categories)
    @categories
  end

  def geolocation_params
    @dist = params[:dist].try(:to_f)
    @addr = params[:addr]
    @city = params[:city]
    @where = params[:where]
    unless (@where || (@lat && @lng))
      respond_with Status.insufficient_arguments({
        :message => 'Needs where you are or latitude/longitude by default'
      }), :location => nil
    end
    {
      :lat => @lat,
      :lng => @lng,
      :dist => @dist || DEFAULT_DISTANCE,
      :city => @city,
      :query => params[:query],
      :addr => @addr,
      :start => @start,
      :limit => @limit
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
      respond_with Status.user_auth_invalid, :location => nil
    end
  end

  def lat_lng_user
    @lat  = params[:lat].try(:to_f)
    @lng  = params[:lng].try(:to_f)
    @user_nid = params[:user_nid]
    @start, @limit = Util.ensure_limit params[:start], params[:limit]
  end

  
end