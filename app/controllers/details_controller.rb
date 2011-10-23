class DetailsController < ApplicationController
  
  respond_to :html, :json
  
  before_filter :parse_params
  before_filter :authentication_required, :only => []
  
  def detail
    
  end
  
  def parse_params
    
  end
  
  def authentication_required
    
  end
  
end