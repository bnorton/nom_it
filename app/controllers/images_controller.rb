class ImagesController < ApplicationController
  
  respond_to :json
  
  before_filter :lat_lng_user
  before_filter :new_image_params, :only => [:create]
  before_filter :image_presence, :only => [:create]
  
  def create
    @image = Image.new(params[:image])
    @image.nid = Util.ID
    @image.user_nid = @user_nid
    @image.location_nid = @location_nid
    resp = if @image.save
      Status.image_saved(@image.nid)
    else
      Status.image_not_saved
    end
    respond_with_location resp
  end

  private

  def _update
    @image = Image.find(params[:id])
    if @image.update_attributes(params[:image])
      redirect_to @image
    end
  end

  def image_presence
    @image = params[:image]
    unless @image.present?
      respond_with_location Status.insufficient_arguments({ :message=>"image upload should have an attached image with the name set to `image[image]` and an original file name"})
    end
  end

  def new_image_params
    @user_nid = params[:user_nid]
    @location_nid = params[:location_nid]
    unless @user_nid.present? && @location_nid.present?
      respond_with_location Status.insufficient_arguments({ :message=>"image upload should have an acting `user_nid` and a target `location_nid`"})
    end
  end
  
  def respond_with_location(resp)
    respond_with resp, :location => '/'
  end
  
  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

end