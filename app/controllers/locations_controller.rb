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
    @primary = params[:primary]
    @text = params[:text]
    @lat = params[:lat]
    @lng = parmas[:lng]
    @addr = params[:addr]
    @city = parmas[:city]
    
    r=nil
    unless (@nid && @token)
      r = Status.insufficient_arguments({:message => 'needs acting user and auth_token'})
    end
    unless r.nil? && (@name && @primary)
      r = Status.insufficient_arguments({:message => 'needs item name and primary category'})
    end
    unless r.nil? && ((@lat && @lng) || (@addr && @city))
      r = Status.insufficient_arguments({:message => 'needs lat/lng or addr/city by default'})
    end
    respond_with r if r.present?
    @creation = {
      :nid => @nid,
      :token => @token,
      :name => @name,
      :primary => @primary,
      :text => @text,
      :lat => @lat,
      :lng => @lng,
      :addr => @addr,
      :city => @city
    }
  end
  
  def authentication_required
    # token from the db must match
  end
  
end