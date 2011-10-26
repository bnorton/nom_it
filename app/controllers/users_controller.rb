
class UsersController < ApplicationController
  
  NUMBER_ARR = /^([0-9]+)(,[0-9]+)*$/  
  
  respond_to :json
  
  before_filter :user_params,       :only => [:me, :login, :register]
  before_filter :auth_params,       :only => [:me, :login, :register]
  before_filter :force_email_passwd,:only => [:login]
  before_filter :search_params,     :only => [:search]
  before_filter :validate_ids,      :only => [:detail]
  before_filter :validate_token,    :only => []
  
  before_filter :authentication_required, :only => [:me]
  
  def me
    me = User.me(@token)
    respond_with Status.OK(me)
  end
  
  def login
    condition = User.login(@email, @password)
    response  = ok_or_not(condition)
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
      
    condition = !registration.blank?
    response  = ok_or_not(condition)
    respond_with response
  end
  
  def detail
    results   = User.detail_for_ids(@ids)
    condition = !results.blank?
    response  = ok_or_not(condition,{:results=>results})
    respond_with response
  end
  
  def search
    results   = User.search_by_all(@query)
    condition = !results.blank?
    response  = ok_or_not(condition,{:results=>results,:not_found=>true})
    respond_with response
  end
  
  private
  
  def ok_or_not(condition,options={})
    if condition && detail = options[:results] || User.detail(@email)
      Status.OK(detail)
    elsif options[:not_found]
      Status.user_not_found
    else
      Status.user_not_authorized
    end
  end
  
  def force_email_passwd
    if @email.blank? || @password.blank?
      respond_with Status.user_not_authorized
    end
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
    @token = @oauth_token = params[:token]
    @registration_type = params[:regtype]
  end
  
  def search_params
    @query = params[:query] || params[:q] || params[:name] || params[:email]
    if @query.blank?
      respond_with Status.user_not_authorized
    end
  end
  
  def validate_ids
    @ids = params[:ids]
    if @ids.blank? || !(@ids =~ NUMBER_ARR)
      respond_with Status.insufficient_arguments
    end
  end
  
  def validate_token
    unless @token && !@token.blank? && User.token_match?(@id,@token)
      respond_with Status.user_not_authorized
    end
  end
  
  
end
