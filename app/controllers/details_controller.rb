class DetailsController < ApplicationController
  
  respond_to :json, :html

  before_filter :lat_lng_user

  def blitz
    respond_with '42'
  end

  def detail
    detail = Detail.build_detail_for_token(@token, @limit)
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

  def heartbeat
    respond_with 'alive'
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @limit = Util.limit(params[:limit], 10)
    @user_nid = params[:user_nid]
  end

end