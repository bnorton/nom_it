
class UsersController < ApplicationController
  
  NUMBER_ARR = /^([0-9A-Za-z]+)(,[0-9A-Za-z]+)*$/  
  
  respond_to :json
  
  before_filter :user_params,       :only => [:me, :login, :register,:thumbs,:thumbed]
  before_filter :auth_params,       :only => [:me, :login, :register]
  before_filter :force_email_passwd,:only => [:login]
  before_filter :search_params,     :only => [:search]
  before_filter :validate_ids,      :only => [:detail,:thumbs,:thumbed]
  before_filter :validate_token,    :only => []
  
  before_filter :authentication_required, :only => [:me,:thumb_create]
  
  # NEW
  # get "user/:nid/thumb"      => "users#thumb_create"                    ## POST
  # get "user/:nid/thumbs"     => "user#thumbs"                           ## POST

  
  def me
    me = User.me(@token)
    respond_with Status.OK(me)
  end
  
  def login
    condition = User.login(@email,@password)
    response  = ok_or_not(condition,{:results=>[{:logged_in=>true}]})
    respond_with response
  end
  
  def register
    registration = case @registration_type
      when 'facebook'
        User.register_with_facebook(@FBHash)
      when 'twitter'
        User.register_with_twitter(@TWHash)
      when 'nom'
        User.register(@email, @password, @screen_name)
      end
      
    condition = !registration.blank?
    response  = ok_or_not(condition,{:results=>response})
    respond_with response
  end
  
  def detail
    results   = User.detail_for_ids(@nids)
    condition = !results.blank?
    response  = ok_or_not(condition,{:results=>results})
    respond_with response
  end
  
  def search
    results   = User.search_by_all(@query,@email,@screen_name)
    condition = !results.blank?
    response  = ok_or_not(condition,{:results=>results,:not_found=>true})
    respond_with response
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
  
  def check
    @screen_name = params[:screen_name]
    response = if @screen_name.blank?
      Status.insufficient_arguments
    else
      if User.find_by_screen_name(@screen_name).blank?
        ok_or_not(true,{:results => [{:detail => 'That name is valid and has been reserved for 5 minutes'}]})
      else
        ok_or_not(true,{:not_found=>true})
      end
    end
    respond_with response
  end
  
  private
  
  def ok_or_not(condition,options={})
    if condition && (detail = options[:results])
      Status.OK(detail)
    elsif options[:not_found]
      Status.user_found
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
    @nid    = params[:nid]
    @nid_them=params[:their_nid]
    @limit  = params[:limit]
    @email  = params[:email] || params[:id]
    @screen_name  = params[:screen_name]
    @FBHash = params[:fbhash]
    @TWHash = params[:twhash]
  end
  
  def auth_params
    @password = params[:password]
    @token = @oauth_token = params[:token]
    @registration_type = params[:regtype] || 'nom'
  end
  
  def search_params
    @query = params[:query] || params[:q]
    @screen_name = params[:screen_name]
    @email = params[:email]
    if !(@query.blank? || @screen_name.blank? || @email.blank?)
      respond_with Status.insufficient_arguments
    end
  end
  
  def validate_ids
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
  
end
