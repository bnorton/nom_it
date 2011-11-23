class DetailsController < ApplicationController
  
  respond_to :json, :html
  
  before_filter :lat_lng_user
  before_filter :parse_params, :except => [:blitz]
  before_filter :authentication_required, :only => []
  
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
      Status.detail_not_found
    end
    respond_with response
  end
  
  def parse_params
    @token = params[:token]
    unless @token
      respond_with Status.insufficient_arguments({:message => 'need a token'})
    end
  end
  
  def authentication_required
    
  end
  
  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

end