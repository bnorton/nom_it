class ImagesController < ApplicationController
  
  respond_to :json
  
  before_filter :new_image_params, :only => [:create]
  
  def create
    @image = Image.new(params[:image])
    @image.nid = Util.ID
    @image.user_nid = @user_nid
    @image.location_nid = @location_nid
    resp = if @image.save
      Status.OK
    else
      Status.image_not_saved
    end
    respond_with resp
  end

  def update
    @image = Image.find(params[:id])
    if @image.update_attributes(params[:image])
      redirect_to @image
    end
  end

  private

  def new_image_params
    @user_nid = params[:user_nid]
    @location_nid = params[:location_nid]
    unless @user_nid.present? && @location_nid.present?
      respond_with Status.insufficient_arguments({
        :message=>"image upload sohuld have an acting `user_nid` and a target `location_nid`"})
    end
  end

end