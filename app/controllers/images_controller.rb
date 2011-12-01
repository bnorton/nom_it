class ImagesController < ApplicationController
  
  respond_to :json

  before_filter :lat_lng_user
  before_filter :new_image_params
  before_filter :image_presence
  before_filter :authentication_required

  def create
    @image = Image.new(@image)
    @image.image_nid = Util.ID
    @image.user_nid = @user_nid
    @image.location_nid = @location_nid
    resp = if @image.save!
      Status.image_saved(@image.image_nid)
    else
      Status.item_not_created 'image'
    end
    respond_with_location resp
  end

  private

  def _update
    @image = Image.find(params[:image_nid])
    if @image.update_attributes(params[:image])
      respond_with_location Status.image_saved(@image.image_nid)
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

  # redirect the user to root upon form posting
  def respond_with_location(resp)
    respond_with resp, :location => '/'
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

  def authentication_required
    @auth_token = params[:auth_token]
    # unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      # respond_with Status.user_auth_invalid
    # end
  end

end