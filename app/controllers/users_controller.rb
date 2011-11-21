
class UsersController < ApplicationController
  
  NUMBER_ARR = /^([0-9A-Za-z]+)(,[0-9A-Za-z]+)*$/  
  
  respond_to :json
  
  before_filter :lat_lng_user
  before_filter :user_params,       :only => [:me, :login, :register,:thumbs,:thumbed]
  before_filter :auth_params,       :only => [:me, :login, :register]
  before_filter :login_required,    :only => [:login]
  before_filter :search_params,     :only => [:search]
  before_filter :validate_nids,      :only => [:detail,:thumbs,:thumbed]
  
  before_filter :authentication_required, :only => [:me,:thumb_create]
  
  def check
    @screen_name = params[:screen_name]
    response = if @screen_name.blank?
      Status.insufficient_arguments
    else
      if (time = User.find_by_screen_name(@screen_name)).blank?
        ok_or_not(true,{:results => [{:reserved_until => Time.now + 1.minutes}]})
      else
        ok_or_not(false,{:name_taken=>true})
      end
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
        User.register(@email, @password, @screen_name, @name, @city)
      end
    condition = registration.present?
    response  = ok_or_not(condition,{:results=>Array(registration)})
    respond_with response
  end
  
  def login
    condition = User.login(@email_or_nid,@password)
    response  = ok_or_not(condition,{:results=>[{:logged_in=>true}]})
    respond_with response
  end
  
  def me
    me = User.me(@token)
    respond_with Status.OK(me)
  end
  
  def detail
    results   = User.detail_for_nids(@nids)
    condition = !results.blank?
    response  = ok_or_not(condition,{:results=>results})
    respond_with response
  end
  
  def search
    @query ||= @screen_name || @email
    results   = User.search_by_all(@query)
    condition = results.present?
    response  = ok_or_not(condition,{:results=>results,:search=>true})
    respond_with response
  end
  
  def activity
    # fetch the thumbs, recomendations and rankings for users this person follows
    
    
  end
  
  # thumb a user
  def thumb_create
    val = params[:value]
    response = if val && Thumb.new_thumb(@nid,@nid_them,val)
      Status.thumb_created
    else
      Status.couldnt_create_new_thumb
    end
    respond_with response
  end
  
  # the users that have thumbed another user  (return people)
  def thumbs
    thumbz,count = Thumb.detail_for_nid(@nid,@limit,:user)
    response = if thumbz.length > 0
      Status.thumbs(thumbz).merge({:thumb_count => count})
    else
      Status.insufficient_arguments
    end
    respond_with response
  end
  
  # things that the user has thumbed (return locatons)
  def thumbed
    
  end
  
  private
  
  def ok_or_not(condition,options={})
    if condition && (detail = options[:results])
      Status.OK(detail)
    elsif options[:name_taken]
      Status.screen_name_taken
    elsif options[:search]
      if condition
        Status.search_result(results)
      else
        Status.not_found
      end
    else
      Status.user_not_authorized
    end
  end
  
  def login_required
    if (@email.blank? || @nid.blank?) || @password.blank?
      respond_with Status.user_not_authorized
    end
  end
  
  def user_params
    @nid_them=params[:their_nid]
    @limit  = params[:limit]
    @email  = params[:email] || params[:nid]
    @screen_name  = params[:screen_name]
    @FBHash = params[:fbhash]
    @TWHash = params[:twhash]
    @name = params[:name]
    @city = params[:city]
  end
  
  def auth_params
    @nid = params[:nid]
    @email_or_nid = @nid || @email
    @password = params[:password]
    @token = @oauth_token = params[:token]
    @registration_type = params[:regtype] || 'nom'
  end
  
  def search_params
    @query = params[:query] || params[:q]
    @screen_name = params[:screen_name]
    @email = params[:email]
    unless @query.present? || @screen_name.present? || @email.present?
      respond_with Status.insufficient_arguments
    end
  end
  
  def validate_nids
    @nid  = params[:nid]
    @nids = params[:nids] || []
    @nids << @nid if @nid.present?
    if @nids.blank? || !(@nids =~ NUMBER_ARR)
      respond_with Status.insufficient_arguments
    end
  end
  
  def validate_token
    unless @token.present? && User.token_match?(@nid,@token)
      respond_with Status.user_not_authorized
    end
  end
  
  def authentication_required
    validate_token
  end
  
  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

end
