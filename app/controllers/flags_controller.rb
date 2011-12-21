class FlagsController < ApplicationController

  respond_to :json

  before_filter :lat_lng_user
  before_filter :authentication_required
  before_filter :common

  def create
    response = if Flag.create(@user_nid,@nid,@type,@severity,@lat,@lng)
      Status.item_created 'flag'
    else
      Status.item_not_created 'flag'
    end
    respond_with response, :location => nil
  end

  private

  def common
    @text = params[:text]
    @severity = params[:severity]
    @nid,@type = params[:image_nid],:image_nid
    @nid,@type = params[:other_user_nid],:user_nid
    @nid,@type = params[:location_nid],:location_nid
    @nid,@type = params[:recommendation_nid],:recommendation_nid
    unless @nid.present? && @type.present?
      respond_with Status.insufficient_arguments, :location => nil
    end
  end

  def authentication_required
    @auth_token = params[:auth_token]
    unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      respond_with Status.user_not_authorized, :location => nil
    end
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end
end
