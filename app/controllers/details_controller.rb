class DetailsController < ApplicationController
  
  before_filter :parse_params
  before_filter :authenticate_request
  
  def detail
    @detail = Recommend.item(@hash)
    
    ser = Serializer.new (@detail)
    respond_to do |wants|
      wants.html 
      wants.json { render :json => ser.to_hash }
    end
  end
  
  def parse_params
    @id    = params[:id]
    @token = params[:token]
    @hash  = params[:hash]
  end
  
  def authenticate_request
    unless User.authentic_request?(@id, @token)
      respond_to do |wants|
        wants.json { render :json => "{\"status\":-1}" }
      end
    end
  end
end