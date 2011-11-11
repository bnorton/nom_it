class LocationsController < ApplicationController
  
  respond_to :json
  
  before_filter :validate_ids
  before_filter :authentication_required, :only => [:edit,:create]
  before_filter :needs_for_create, :only => [:create]
  
  def detail
    response = if (locations = Location.detail_for_ids(@locations))
      Status.locations(locations)
    else
      Status.no_locations_found
    end
    respond_with response
  end
  
  def edit
    
  end
  
  # # required
  # @nid
  # @token
  # @name
  # @primary
  # (@lat AND @lng) OR @city
  # # optional
  # @text
  
  def create
    Location.create
  end
  
  ## NEW
  # get "location/:nid/thumb"  => "locations#thumb_create"                ## POST
  # get "location/:nid/thumbs" => "locations#thumbs"                      ## POST
  
  def validate_ids
    @locations  = params[:nids] || []
    @locations << params[:nid]
    @locations = @locations.respond_to?(:split) ? @locations.split(',') : @locations
    flag = false
    unless @locations.is_a?(Array) && @locations.length > 0
      flag = true
    else
      @locations.each do |l|
        flag = true unless l.is_a? Fixnum
      end
    end
    respond_with Status.location_not_properly_formatted({:plural=>true}) if flag
  end
  
  def needs_for_create
    @nid = params[:nid]
    @token = params[:token]
    @name = params[:name]
    @primary = params[:primary]
    @text = params[:text]
    @lat = params[:lat]
    @lng = parmas[:lng]
    @city = parmas[:city]
    
    unless (@nid && @token)
      r = Status.insufficient_arguments({:message => 'needs acting user and auth_token'})
    end
    unless (@name && @primary)
      r = Status.insufficient_arguments({:message => 'needs item name and primary category'})
    end
    unless (@lat && @lng) || @city
      r = Status.insufficient_arguments({:message => 'needs lat and lng by default'})
    end
    respond_with r in r.present?
  end
  
  def authentication_required
    # token from the db must match
  end
  
end