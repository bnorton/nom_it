
class UsersController < ApplicationController
  
  respond_to :json
  
  before_filter :authenticate_user, :only => [:login]
  before_filter :user_params,       :only => [:me, :login, :register]
  before_filter :auth_params,       :only => [:me, :login, :register]
  before_filter :required_params,   :only => [:login, :register]
  
  def me
    me = User.me(@token)
    respond_with Status.OK(me)
  end
  
  def login
    response = if User.login(@email, @password) && detail = User.detail(@email)
      Status.OK(detail) # Status.OK(detail,{:result_name => :users})
    else
      Status.user_not_authorized
    end
    respond_with response
  end
  
  def register
    registration = case @registration_type
      when 'facebook'
        User.register_with_facebook(@FBHash)
      when 'twitter'
        User.register_with_twitter(@TWHash)
      when 'nom'
        User.register(@email, @password, @vname)
      end
      
      response = if registration.nil?
        Status.user_not_authorized
      else
        # Status.user_detail(User.detail(@email))
        detail = User.detail(@email)
        Status.OK(detail)
      end
    respond_with response
  end
  
  private
  
  def required_params
    if @email.blank? || @password.blank?
      respond_with Status.user_not_authorized
    end
  end
  
  def authenticate_user
    
  end
  
  def user_params
    @id     = params[:id]
    @email  = params[:email]
    @vname  = params[:vanme]
    @FBHash = params[:fbhash]
    @TWHash = params[:twhash]
  end
  
  def auth_params
    @password = params[:password]
    @oauth_token  = params[:token]
    @registration_type = params[:regtype]
  end
    
  def validate_token
    
  end
end
