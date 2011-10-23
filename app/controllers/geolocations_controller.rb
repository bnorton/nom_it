class GeolocationsController < ApplicationController
  
  DEFAULT_DISTANCE = 0.5
  
  respond_to :json
  
  before_filter :lat_lng_dist, :only => [:here, :search]
  before_filter :primary,      :only => [:search]
  before_filter :secondary,    :only => [:search]
  before_filter :authentication_required, :only => []
  
  def here
    @search = Geolocation.search_by_geolocation(@lat,@lng,@dist)
    self.details
  end
  
  def search
    @search = Geolocation.category_search(@lat,@lng,@dist,@primary,@secondary)
    self.details
  end
  
  def details
    details= Location.details_from_search(@search)
    response = unless details
      Status.unknown_error
    else
      Status.OK(details)
    end
    respond_with response
  end
  
  def lat_lng_dist
    @lat  = params[:lat]
    @lng  = params[:lng]
    @dist = params[:dist] || DEFAULT_DISTANCE
    unless @lat && @lng && @dist
      respond_with Status.insufficient_arguments({:message => 'needs lat and lng by default'})
    end
  end
  
  def primary
    @primary   = params[:primary]
  end
  
  def secondary
    @secondary = params[:secondary]
  end
  
  def authentication_required
    
  end
  
end