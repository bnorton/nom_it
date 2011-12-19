class ThumbsController < ApplicationController

  respond_to :json
  
  before_filter :common
  before_filter :location_params, :only => [:location_new]
  before_filter :to_user_params, :only => [:user_new]
  before_filter :authentication_required, :only => [:user_new,:location_new]

  def create
    thumb = Thumb.new_thumb(@item,@user_nid,@value)
    response = if thumb.present?
      Status.item_created 'thumb'
    else
      Status.item_not_created 'thumb'
    end
    respond_with response, :location => nil
  end

  def location_new
    @item = @location_nid
    create
  end

  def user_new
    @item = @to_user_nid
    create
  end

  def thumbs
    item,what = @user_nid,:user_nid
    item,what = @location_nid,:location_nid if @location_nid.present?
    thumbz = Thumb.detail_for_nid(item,@limit,what)
    response = if thumbz.present?
      Status.OK(thumbz)
    else
      Status.not_found 'thumbs'
    end
    respond_with response
  end
  
  def thumbed
    thumbs = Thumb.for_unids(@user_nid,@limit)
    response = if thumbs.present?
      Status.thumbs thumbs
    else
      Status.not_found 'thumbs'
    end
    respond_with response
  end

  # the users that have thumbed another user  (return people)

  def thumbs
    
  end

  def thumbed
    
  end
  
  private

  def location_params
    @location_nid = params[:location_nid]
    unless @location_nid.present?
      respond_with Status.insufficient_arguments, :location => nil
    end
  end

  def to_user_params
    @to_user_nid = params[:to_user_nid]
    unless @to_user_nid.present?
      respond_with Status.insufficient_arguments, :location => nil
    end
  end

  def common
    @limit = Util.limit(params[:limit])
    @value = params[:value]
    @user_nid = params[:user_nid]
  end

  def authentication_required
    @auth_token = params[:auth_token]
    unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      respond_with Status.user_auth_invalid, :location => nil
    end
  end
end