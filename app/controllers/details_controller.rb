class DetailsController < ApplicationController
  
  respond_to :json, :html

  before_filter :lat_lng_user, :except => [:detail]
  before_filter :tokens, :only => [:detail]

  def blitz
    respond_with '42'
  end

  def index
  end
  def project
  end
  def algorithms
  end
  def team
  end
  def help
  end

  def detail
    @detail = Detail.build_detail_for_token(@token, @limit)
    @response = if @detail.present?
      Status.OK(@detail)
    else
      Status.not_found 'detail'
    end
    respond_with @response
  end

  def heartbeat
    respond_with 'alive'
  end

  private

  def tokens
    @token = params[:token]
    @limit = Util.limit(params[:limit], 10)
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @limit = Util.limit(params[:limit], 10)
    @user_nid = params[:user_nid]
  end

end