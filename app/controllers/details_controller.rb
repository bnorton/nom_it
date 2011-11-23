class DetailsController < ApplicationController
  
  respond_to :json, :html

  before_filter :lat_lng_user

  def blitz
    respond_with '42'
  end

  def detail
    detail = Detail.build_detail_for_token(@token)
    response = if detail && detail.length > 1
        resp = {
          :recommendation => detail[:recommendation],
          :metadata => detail[:metadata]
        }
        Status.detail(resp)
    else
      Status.not_found 'detail'
    end
    respond_with response
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

end