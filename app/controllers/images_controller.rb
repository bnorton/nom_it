class ImagesComtroller < ApplicationController
  
  respond_to :json
  
  before_filter :check_args, :only => [:upload]
  before_filter :authentication_required, :only => [:upload, :commit_upload]
  
  def upload
    respond_with Status.insufficient_arguments({:message => "ImagesComtroller#upload"})
  end
  
  def commit_upload
    respond_with Status.insufficient_arguments({:message => "ImagesComtroller#commit_upload"})
  end
  
  def check_args
    @id       = params[:id]
    @location = params[:location_id]
    @iname    = params[:iname]
  end
  
  def authentication_required
    
  end
  
end