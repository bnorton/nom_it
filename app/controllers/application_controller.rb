class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :verify_connection

  # any model will do
  def verify_connection
    User.verify_active_connections!
  end

end
