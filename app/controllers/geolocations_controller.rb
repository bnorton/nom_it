class GeolocationsController < ApplicationController
  
  DEFAULT_DISTANCE = 0.5

  respond_to :json

  before_filter :lat_lng_user
  before_filter :lat_lng_dist, :only => [:here, :search]

  def here
    @search = Geolocation.search(@lat,@lng,@dist,@primary,@secondary,@start,@limit)
    details
  end

  def details
    details = Location.full_details_from_search(@search)
    response = if details.present?
      Status.OK(details)
    else
      Status.unknown_error
    end
    respond_with response
  end

  def lat_lng_dist
    @lat = params[:lat]
    @lng = params[:lng]
    @user_nid = params[:user_nid]
    unless @lat && @lng
      respond_with Status.insufficient_arguments({:message => 'needs lat and lng by default'})
    end
    @dist = params[:dist] || DEFAULT_DISTANCE,
    @start = params[:start]
    @limit = Util.limit(params[:limit])
    @primary = params[:primary]
    @secondary = params[:secondary]
  end
end