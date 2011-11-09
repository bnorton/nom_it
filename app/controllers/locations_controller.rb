class LocationsController < ApplicationController
  
  respond_to :json
  
  before_filter :validate_ids
  before_filter :authentication_required, :only => [:edit]
  
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
  
  def validate_ids
    @locations  = params[:ids] || []
    @locations << params[:id]
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
  
  def authentication_required
    
  end
  
end